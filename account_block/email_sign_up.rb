module AccountBlock
    class AccountsController < ApplicationController
      include BuilderJsonWebToken::JsonWebTokenValidation
  
      LOWER_EMAIL = 'LOWER(email) = ?'
  
      def create
        if params[:data][:type] = "email_account"
            account_params = jsonapi_deserialize(params)
            query_email = account_params['email'].downcase
            account =EmailAccount.where(LOWER_EMAIL, query_email).where(activated: true).first
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
            if @account.save
              @account.generate_otp
              @account.update(token: encode(@account.id))
              AccountBlock::EmailValidationMailer.with(account: @account, host: request.base_url).activation_email.deliver
              render json: EmailAccountSerializer.new(@account, meta: { token: @account.token }).serializable_hash,
                     status: :created
            else
              render json: { errors: format_activerecord_errors(@account.errors) }, status: :unprocessable_entity
            end
        end
      end
  
      def verify_otp
        params[:data][:type] = "email_account"
        email = params.dig(:data, :attributes, :email)&.downcase
        account =  Account.find_by(LOWER_EMAIL, email)
        if account
          otp = params.dig(:data, :attributes, :otp)
          if account.otp == otp
            if account.otp_expired?
              render json: { errors: [{ message: 'OTP has expired' }] }, status: :unprocessable_entity
              return
            end
            if account.save(validate: false)
              account.update(activated: true)
              render json: { success: [{ email: account.email }, { message: 'OTP verified' }] }, status: :ok
            end
          else
            render json: { errors: [{ message: 'Incorrect OTP' }] }, status: :unprocessable_entity
          end
            
        else
          render json: { errors: [{ message: 'The email is not present' }] }, status: :unprocessable_entity
        end
      end
  
      def resend_otp
        token = request.headers['Authorization'].to_s.split(' ').last
        if token.present?
          @account = AccountBlock::Account.find_by(token: token)
          if @account
            @account.generate_otp
        
            if @account.save(validate: false)
              EmailValidationMailer.with(account: @account, host: request.base_url).activation_email.deliver
              render json: EmailAccountSerializer.new(@account, meta: {
                                                        token: encode(@account.id)
                                                      }).serializable_hash, status: :created
            else
              render json: { errors: format_activerecord_errors(@account.errors) },
                     status: :unprocessable_entity
            end
          else
            render json: { errors: [{ message: 'account not found' }] }, status: :unprocessable_entity 
          end
        else
          render json: { errors: [{ message: 'token not found' }] }, status: :unprocessable_entity 
        end
      end
  
      def upload_profile_picture
        account = AccountBlock::Account.find_by(id: params[:id])
        if account.present? && account.update(profile_picture: params[:profile_picture])
          render json: AccountBlock::AccountSerializer.new(account, serialization_options).serializable_hash, status: :ok 
        else
          render json: { message: "Account not present OR provided wrong parameters" }, status: 404
        end
      end
  
      private
  
      def serialization_options
        { params: { host: request.protocol + request.host_with_port } }
      end
  
      def encode(id)
        BuilderJsonWebToken.encode id
      end
  
      def remove_unverified_email(arg, type)
        if type == 'email_account'
          account_unverified = EmailAccount.where(LOWER_EMAIL, arg.downcase).where(activated: false)
          account_unverified&.destroy_all
        end
      end
    end
  end
  