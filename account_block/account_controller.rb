
module AccountBlock
    class AccountsController < ApplicationController
      protect_from_forgery with: :null_session
      include BuilderJsonWebToken::JsonWebTokenValidation
      before_action :validate_json_web_token, only: :search
      before_action :find_account, only: :resend_otp
      LOWER_EMAIL = 'LOWER(email) = ?'
      def create
        case params[:data][:type]
        when 'sms_account'
          create_sms_account
        when 'email_account'
          create_email_account
        when 'social_account'
          create_social_account
        else
          render json: { errors: [{ account: 'Invalid Account Type' }] }, status: :unprocessable_entity
        end
      end
      def verify_otp
        # otp verified here
        case params[:data][:type]
        when 'email_account'
          email = params.dig(:data, :attributes, :email)&.downcase
          if email.blank?
            render json: { errors: [{ message: 'Email is required' }] }, status: :unprocessable_entity
            return
          end
          account = Account.find_by(LOWER_EMAIL, email)
          if account
            otp = params.dig(:data, :attributes, :otp).to_i
            if account.otp == otp
              account.otp_verified = true
              if account.save(validate: false)
                render json: { success: [{ email: account.email }, { message: 'OTP verified' }] }, status: :ok
              else
                render json: { errors: [{ message: 'Account does not verified' }] }, status: :unprocessable_entity
              end
            else
              render json: { errors: [{ message: 'Incorrect OTP' }] }, status: :unprocessable_entity
            end
          else
            render json: { errors: [{ message: 'The email is not present' }] }, status: :unprocessable_entity
          end
        when 'sms_account'
          type = params[:data][:attributes]
          number = params[:data][:attributes][:full_phone_number]
          country_code = params[:data][:attributes][:country_code]
          otp = params[:data][:attributes][:otp].to_i
          unless country_code.present?
            return render json: { errors: [country_code: 'Please Enter a country Code'] }, status: :unprocessable_entity
          end
          @account = AccountSms.verify_otp(type, number, otp, country_code)
          case @account
          when 'otp not equal'
            render json: { errors: [{ message: 'incorrect OTP' }] }, status: :unprocessable_entity
          when 'account not present'
            render json: { errors: [{ message: 'the phone number is not present' }] }, status: :unprocessable_entity
          else
            render json: { success: [{ full_phone_number: @account.full_phone_number }, { message: 'verified sms otp' }] },
                   status: :ok
          end
        end
      end
      def create_password
        # password being created
        # token was sent back for the login during sign up
        case params[:data][:type]
        when 'email_account'
          email = params[:data][:attributes][:email].to_s.downcase
          password = params[:data][:attributes][:password].to_s
          confirm_password = params[:data][:attributes][:confirm_password].to_s
          account = Account.where(LOWER_EMAIL, email).first
          if account.present? && (account.otp_verified == true)
            if password.length.positive?
              if (password == confirm_password) && password.present? && confirm_password.present?
                unless account.update(activated: true, password: params[:data][:attributes][:password])
                  return render json: { errors: [{ message: 'password will have minimum six characters and alpha-numeric values' }] },
                                status: :unprocessable_entity
                end
                AccountBlock::CreateEmailMailer.with(account: account, host: request.base_url).create_email.deliver
                BxBlockCart::Cart.create(account_id: account.id)
                BxBlockWishlist2::Wishlist.create(account_id: account.id)
                account = OpenStruct.new(jsonapi_deserialize(params))
                account.type = params[:data][:type]
                output = BxBlockLogin::AccountAdapter.new
                output.on(:successful_login) do |account, token, refresh_token|
                  render json: { meta: {
                    token: token,
                    refresh_token: refresh_token,
                    id: account.id,
                    success: [{ message: 'the account has been created' }]
                  } }
                end
                output.login_account(account)
              else
                render json: { errors: [{ message: 'password and confirm password should be same' }] },
                       status: :unprocessable_entity
              end
            else
              render json: { errors: [{ message: 'password is required' }] }, status: :unprocessable_entity
            end
          else
            render json: { errors: [{ message: 'no  active account by this email is present?' }] },
                   status: :unprocessable_entity
          end
        when 'sms_account'
          number = params[:data][:attributes][:full_phone_number].to_s
          password = params[:data][:attributes][:password].to_s
          confirm_password = params[:data][:attributes][:confirm_password].to_s
          country_code = params[:data][:attributes][:country_code].to_i
          account = SmsAccount.where(full_phone_number: number, country_code: country_code).first
          if account.present? && (account.otp_verified == true)
            if (password == confirm_password) && password.present? && confirm_password.present?
              unless account.update(activated: true, password: params[:data][:attributes][:password])
                return render json: { errors: [{ message: 'password will have minimum six characters and alpha-numeric values and minimum on capital alphabet' }] },
                              status: :unprocessable_entity
              end
              # account.activated = true
              # account.password = params[:data][:attributes][:password]
              account.save
              BxBlockCart::Cart.create(account_id: account.id)
              account = OpenStruct.new(jsonapi_deserialize(params))
              account.type = params[:data][:type]
              output = BxBlockLogin::AccountAdapter.new
              output.on(:successful_login) do |account, token, refresh_token|
                render json: { meta: {
                  token: token,
                  refresh_token: refresh_token,
                  id: account.id,
                  success: [{ message: 'the account has been created' }]
                } }
              end
              output.login_account(account)
            else
              render json: { errors: [{ message: 'password and confirm password are uneqal' }] },
                     status: :unprocessable_entity
            end
          else
            render json: { errors: [{ message: 'no  active account by this number is present?' }] },
                   status: :unprocessable_entity
          end
        end
      end
      def forgot_password
        case params[:data][:type]
        when 'email_account'
          account_params = jsonapi_deserialize(params)
          @account = ForgotPassword.forgot_password(account_params)
          case @account
          when 'blank email'
            render json: { errors: [{ message: 'email cannot be blank' }] }, status: :unprocessable_entity
          when 'invalid email'
            render json: { errors: [{ message: 'email invalid format!' }] }, status: :unprocessable_entity
          when 'not exist'
            render json: { errors: [{ message: 'account does not exist! please sign up' }] },
                   status: :unprocessable_entity
          else
            EmailValidationMailer
              .with(account: @account, host: request.base_url)
              .activation_email.deliver
            render json: EmailAccountSerializer.new(@account, meta: {
                                                      token: encode(@account.id)
                                                    }).serializable_hash, status: :ok
          end
        when 'sms_account'
          account_params = jsonapi_deserialize(params)
          unless Phonelib.valid?(account_params['country_code'] + account_params['full_phone_number'])
            return render json: { errors: [country_code: 'Please Enter a Valid Number'] }
          end
          @account = AccountSms.forgot_password(account_params)
          if @account&.present? && @account.class != String
            render json: SmsAccountSerializer.new(@account, meta: {
                                                    token: encode(@account.id)
                                                  }).serializable_hash, status: :created
          elsif @account == 'account not present'
            render json: { errors: [{ message: 'account is not present' }] }, status: :unprocessable_entity
          else
            render json: { errors: [{ message: 'otp was not generated for the email' }] }, status: :unprocessable_entity
          end
        end
      end
      def verify_otp_forgot
        # otp verified here
        case params[:data][:type]
        when 'email_account'
          @email = params[:data][:attributes][:email].downcase
          otp = params[:data][:attributes][:otp].to_i
          @account = VerifyOtpForgot.verify_otp(@email, otp)
          if @account.present? && @account.class != String
            render json: { success: [{ email: @account.email }, { message: 'forget otp verified ' }] }, status: :ok
          elsif @account == 'unequal OTP'
            render json: { errors: [{ message: 'incorrect otp' }] }, status: :ok
          elsif @account == 'not verified'
            render json: { errors: [{ message: 'not verified otp' }] }, status: :ok
          elsif @account == 'blank'
            render json: { errors: [{ message: 'email cannot be blank' }] }, status: :ok
          else
            render json: { errors: [{ message: 'The email is not present' }] }, status: :unprocessable_entity
          end
        when 'sms_account'
          type = params[:data]
          number = params[:data][:attributes][:full_phone_number]
          otp = params[:data][:attributes][:otp]
          code = params[:data][:attributes][:country_code]
          @account = AccountSms.verify_otp_forgot(number, otp, code)
          if @account.present? && @account.class != String
            render json: { success: [{ full_phone_number: @account.full_phone_number }, { message: 'verified otp' }] },
                   status: :ok
          elsif @account == 'unequal OTP'
            render json: { errors: [{ message: 'incorrect otp' }] }, status: :ok
          elsif @account == 'not verified'
            render json: { errors: [{ message: 'not verified otp' }] }, status: :ok
          else
            render json: { errors: [{ message: 'The phone number  is not present' }] }, status: :unprocessable_entity
          end
        end
      end
      def reset_password
        # reset password here
        case params[:data][:type]
        when 'email_account'
          email = params[:data][:attributes][:email].downcase
          password = params[:data][:attributes][:password].to_s
          confirm_password = params[:data][:attributes][:confirm_password].to_s
          account = Account.where(LOWER_EMAIL, email).first
          if account.present? && (account.otp_verified == true)
            if (password == confirm_password) && password.present? && confirm_password.present?
              account.activated = true
              account.password = params[:data][:attributes][:password]
              unless account.update(activated: true, password: password)
                return render json: { errors: [{ message: 'password will have minimum six characters and alpha-numeric values' }] },
                              status: :unprocessable_entity
              end
              account = OpenStruct.new(jsonapi_deserialize(params))
              account.type = params[:data][:type]
              output = BxBlockLogin::AccountAdapter.new
              AccountBlock::ResetPasswordMailer.with(account: account, host: request.base_url).reset_password.deliver
              output.on(:successful_login) do |account, token, refresh_token|
                render json: { meta: {
                  token: token,
                  refresh_token: refresh_token,
                  id: account.id,
                  success: [{ message: 'The account has been recovered' }]
                } }
              end
              output.login_account(account)
            elsif password.blank?
              render json: { errors: [{ message: 'password cannot be blank' }] }, status: :unprocessable_entity
            else
              render json: { errors: [{ message: 'password and confirm password are uneqal' }] },
                     status: :unprocessable_entity
            end
          elsif email.blank?
            render json: { errors: [{ message: 'email cannot be blank' }] }, status: :unprocessable_entity
          else
            render json: { errors: [{ message: 'no account by this email is present?' }] }, status: :unprocessable_entity
          end
        when 'sms_account'
          number = params[:data][:attributes][:full_phone_number]
          password = params[:data][:attributes][:password].to_s
          confirm_password = params[:data][:attributes][:confirm_password].to_s
          code = params[:data][:attributes][:country_code]
          account = AccountSms.reset_password(number, password, confirm_password, code)
          if account.present? && account.class != String
            unless account.update(activated: true, password: params[:data][:attributes][:password])
              return render json: { errors: [{ message: 'password will have minimum six characters and alpha-numeric values' }] },
                            status: :unprocessable_entity
            end
            account = OpenStruct.new(jsonapi_deserialize(params))
            account.type = params[:data][:type]
            output = BxBlockLogin::AccountAdapter.new
            output.on(:successful_login) do |account, token, refresh_token|
              render json: { meta: {
                token: token,
                refresh_token: refresh_token,
                id: account.id,
                success: [{ message: 'The account has been recovered' }]
              } }
            end
            output.login_account(account)
          elsif account == 'unequal password'
            render json: { errors: [{ message: 'password and confirm password are uneqal' }] },
                   status: :unprocessable_entity
          elsif account == 'no account is present'
            render json: { errors: [{ message: 'no account by this phone number is present?' }] },
                   status: :unprocessable_entity
          end
        end
      end
      def resend_otp
        @account.otp = rand(1000..9999)
        @account.otp_verified = false
        if params[:data][:type] == 'email_account'
          if @account.save(validate: false)
            # EmailAccount.create_stripe_customers(@account)
            EmailValidationMailer
              .with(account: @account, host: request.base_url)
              .activation_email.deliver
            render json: EmailAccountSerializer.new(@account, meta: {
                                                      token: encode(@account.id)
                                                    }).serializable_hash, status: :created
          else
            render json: { errors: format_activerecord_errors(@account.errors) },
                   status: :unprocessable_entity
          end
        elsif @account.save(validate: false)
          country_code = @account.country_code
          SendOtpNumberService.new(@account, @account.full_phone_number).send_otp_forgot
          # EmailAccount.create_stripe_customers(@account)
          render json: SmsAccountSerializer.new(@account, meta: {
                                                  token: encode(@account.id)
                                                }).serializable_hash, status: :created
        else
          render json: { errors: format_activerecord_errors(@account.errors) },
                 status: :unprocessable_entity
        end
      end
      private
      def create_sms_account
        type = params[:data][:type]
        number = params[:data][:attributes][:full_phone_number]
        country_code = params[:data][:attributes][:country_code]
        if country_code.nil?
          render json: {
            errors: {
              country_code: 'Please enter a country code'
            }
          }, status: :unprocessable_entity
          return
        end
        unless Phonelib.valid?(number)
          render json: { errors: {
            country_code: 'Please enter a valid number'
          } }, status: :unprocessable_entity
          return
        end
        query_number = SmsAccount.find_by(full_phone_number: number, activated: true)
        if query_number
          render json: { errors: [{ account: 'Number has already been taken' }] }, status: :unprocessable_entity
        else
          remove_unverified_email(number, 'sms_account')
          @account = AccountSms.new(type, number, country_code).create_sms_account
          @account.save
          SendOtpNumberService.new(@account, @account.full_phone_number).send_otp
          render json: SmsAccountSerializer.new(@account, meta: { token: encode(@account.id) }).serializable_hash,
                 status: :created
        end
      end
      def create_email_account
        account_params = jsonapi_deserialize(params)
        query_email = account_params['email'].downcase
        account = EmailAccount.where(LOWER_EMAIL, query_email).where(activated: true).first
        remove_unverified_email(query_email, 'email_account')
        validator = EmailValidation.new(account_params['email'])
        if account_params['email'].blank?
          render json: { errors: [{ account: 'Email address is required' }] }, status: :unprocessable_entity
          return
        end
        if account
          render json: { errors: [{ account: 'Email has already been taken' }] }, status: :unprocessable_entity
          return
        end
        unless validator.valid?
          render json: { errors: [{ account: 'Email is not in the valid format' }] }, status: :unprocessable_entity
          return
        end
        @account = EmailAccount.new(jsonapi_deserialize(params))
        @account.platform = request.headers['platform'].downcase if request.headers.include?('platform')
        @account.otp = rand(1000..9999)
        if @account.save
          EmailValidationMailer.with(account: @account, host: request.base_url).activation_email.deliver
          render json: EmailAccountSerializer.new(@account, meta: { token: encode(@account.id) }).serializable_hash,
                 status: :created
        else
          render json: { errors: format_activerecord_errors(@account.errors) }, status: :unprocessable_entity
        end
      end
      def create_social_account
        @account = SocialAccount.new(jsonapi_deserialize(params))
        @account.password = @account.email
        if @account.save
          render json: SocialAccountSerializer.new(@account, meta: { token: encode(@account.id) }).serializable_hash,
                 status: :created
        else
          render json: { errors: format_activerecord_errors(@account.errors) }, status: :unprocessable_entity
        end
      end
      def encode(id)
        BuilderJsonWebToken.encode id
      end
      def remove_unverified_email(arg, type)
        if type == 'email_account'
          account_unverified = EmailAccount.where(LOWER_EMAIL, arg.downcase).where(activated: false)
          account_unverified&.destroy_all
        else
          account_unverified = SmsAccount.where(full_phone_number: arg, activated: false)
          account_unverified&.destroy_all if account_unverified.length >= 1
        end
      end
      def find_account
        account_params = jsonapi_deserialize(params)
        case params[:data][:type]
        when 'email_account'
          query_email = account_params['email'].downcase
          @account = EmailAccount.where(LOWER_EMAIL, query_email).first
        else
          query_number = account_params['full_phone_number']
          country_code = account_params['country_code']
          @account = SmsAccount.where(full_phone_number: query_number, country_code: country_code).first
        end
        return if @account.present?
        render json: { errors: [
          { account: 'email does not exist ' }
        ] }, status: :unprocessable_entity
      end
    end
  end