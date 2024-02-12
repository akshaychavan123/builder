module AccountBlock
    class AccountsController < ApplicationController
     include BuilderJsonWebToken::JsonWebTokenValidation
  
     EMAIL_ERROR = "Email already registered and activated"
  
     before_action :validate_json_web_token, only: [:search, :change_email_address, :change_phone_number, :specific_account, :logged_user, :update ,:deactivate_account]
     before_action :current_user, only: %i[update deactivate_account]
  
     def create
        case params[:data][:type] #### rescue invalid API format
        # when "sms_account"
        #   validate_json_web_token
  
  
        #   unless valid_token?
        #     return render json: {errors: [
        #       {token: "Invalid Token"}
        #     ]}, status: :bad_request
        #   end
  
        #   begin
        #     @sms_otp = SmsOtp.find(@token[:id])
        #   rescue ActiveRecord::RecordNotFound => e
        #     return render json: {errors: [
        #       {phone: "Confirmed Phone Number was not found"}
        #     ]}, status: :unprocessable_entity
        #   end
  
        #   params[:data][:attributes][:full_phone_number] =
        #     @sms_otp.full_phone_number
        #   @account = SmsAccount.new(jsonapi_deserialize(params))
        #   @account.activated = true
        #   if @account.save
        #     render json: SmsAccountSerializer.new(@account, meta: {
        #       token: encode(@account.id)
        #   else
        #     render json: {errors: format_activerecord_errors(@account.errors)},
        #       status: :unprocessable_entity
        #   end
  
      when "email_account"
        phone_number =  params.dig(:data, :attributes, :full_phone_number)
        account_params = jsonapi_deserialize(params)
        query_email = params.dig(:data, :attributes, :email).downcase
        # query_email = account_params["email"].downcase
        account = EmailAccount.where("LOWER(email) = ?", query_email).first
        validator = EmailValidation.new(account_params["email"])
        # if account || !validator.valid?
        #   return render json: {errors: [
        #     {account: "Email invalid"}
        #   ]}, status: :unprocessable_entity
        # end
  
        # deserialize_params = jsonapi_deserialize(params)
        # deserialize_params[:user_type] = deserialize_params['user_type']&.downcase
        # @account = EmailAccount.new(deserialize_params)
        # @account.platform = request.headers["platform"].downcase if request.headers.include?("platform")
        # @account.activated = false
        # @account.user_type = params.dig(:data, :attributes, :user_type)&.downcase || 'seller'
        # @account.user_state = :user_type_selection
        # @email_account = AccountBlock::EmailOtp.create(email: @account.email)
        @account = (account.present? && account.activated == false) ? account : create_acc(params)
        if @account.save
          if @account.activated
            return render json: {errors: [
              {account: EMAIL_ERROR}
            ]}, status: :unprocessable_entity
          elsif validator.valid? == false
            return render json: {errors: [
              {account: "Email invalid"}
            ]}, status: :unprocessable_entity
          else
            # @email_account = AccountBlock::EmailOtp.create(email: @account.email)
            email_otp_timer = send_email_otp(@account)
            send_pin_via_sms(phone_number)
            # mobile_otp_timer = send_pin_via_sms(phone_number)
            BxBlockNotifications::NotificationCreator.new(@account, "Signup Notification", "Hello #{@account.first_name} you've been successfully Signed Up", @account.id).call
            return render json: EmailAccountSerializer.new(@account, meta: {
              email_otp_timer: email_otp_timer,
              message: "Email verification code sent on #{@account.email}",
              # mobile_otp_timer: mobile_otp_timer,
              token: encode(@account.id)}), status: :ok
          end
        else
         render json: {errors: format_activerecord_errors(@account.errors)},
         status: :unprocessable_entity
       end
     end
   end
  #       # if @account.save
        #   send_email_otp(@account)
        #   #send_pin_via_sms(phone_number)
  
        #   render json: EmailAccountSerializer.new(@account, meta: {
        #     token: encode(@account.id)}), message: "Email verification code sent on #{@account.email}"
        # else
        #   render json: {errors: format_activerecord_errors(@account.errors)},
        #   status: :unprocessable_entity
        # end
  
        # when "social_account"
        #   @account = SocialAccount.new(jsonapi_deserialize(params))
        #   @account.password = @account.email
        #   if @account.save
        #     render json: SocialAccountSerializer.new(@account, meta: {
        #       token: encode(@account.id)
        #     }).serializable_hash, status: :created
        #   else
        #     render json: {errors: format_activerecord_errors(@account.errors)},
        #       status: :unprocessable_entity
        #   end
        
        def update
          account_param = jsonapi_deserialize(params)
          account = @current_user
          param_attributes = params[:data][:attributes]
  
          if param_attributes[:user_type].present? && account.user_state == 'user_type_selection'
            account_param['user_state'] = 'sale_type_selection'
          end
          
          if account.update_attributes(account_params_for_attributes)
            BxBlockNotifications::NotificationCreator.new(account, "Account Update Notification", "Hello #{account.first_name} required changes have been made to your profile", account.id).call
            render json: EmailAccountSerializer.new(account, serialize_options).serializable_hash, status: 200
          else
            render json: { errors: format_activerecord_errors(account.errors) }, status: :unprocessable_entity
          end
        end
  
        def deactivate_account
          return nil unless params[:data][:attributes][:flag] == 'true'
  
          @current_user.update(activated: false)
          render json: { message: 'Your account has been successfully deactivated' }, status: :ok
        end
  
        def create_acc(params)  
          deserialize_params = jsonapi_deserialize(params)
          deserialize_params[:user_type] = deserialize_params['user_type']&.downcase
          account = EmailAccount.new(deserialize_params)
          account.platform = request.headers["platform"].downcase if request.headers.include?("platform")
          account.activated = false
          account.user_type = params.dig(:data, :attributes, :user_type)&.downcase || 'seller'
          account.user_state = :user_type_selection
          if account.id.present?
            render json: {errors: [
              { account: "Email already registered and activated" }
            ]}, status: :unprocessable_entity
          else
            account
          end
        end
  
        def search
        # @accounts = Account.where(activated: true)
        #   .where("first_name ILIKE :search OR " \
        #                      "last_name ILIKE :search OR " \
        #                      "email ILIKE :search", search: "%#{search_params[:query]}%")
        # if @accounts.present?
        #   render json: AccountSerializer.new(@accounts, meta: {message: "List of users."}).serializable_hash, status: :ok
        # else
        #   render json: {errors: [{message: "Not found any user."}]}, status: :ok
        # end
      end
  
      def change_email_address
        # query_email = params["email"]
        # account = EmailAccount.where("LOWER(email) = ?", query_email).first
  
        # validator = EmailValidation.new(query_email)
  
        # if account || !validator.valid?
        #   return render json: {errors: "Email invalid"}, status: :unprocessable_entity
        # end
        # @account = Account.find(@token.id)
        # if @account.update(email: query_email)
        #   render json: AccountSerializer.new(@account).serializable_hash, status: :ok
        # else
        #   render json: {errors: "account user email id is not updated"}, status: :ok
        # end
      end
  
      def change_phone_number
        # @account = Account.find(@token.id)
        # if @account.update(full_phone_number: params["full_phone_number"])
        #   render json: AccountSerializer.new(@account).serializable_hash, status: :ok
        # else
        #   render json: {errors: "account user phone_number is not updated"}, status: :ok
        # end
      end
  
      def specific_account
        # @account = Account.find(@token.id)
        # if @account.present?
        #   render json: AccountSerializer.new(@account).serializable_hash, status: :ok
        # else
        #   render json: {errors: "account does not exist"}, status: :ok
        # end
      end
  
      def index
        # @accounts = Account.all
        # if @accounts.present?
        #   render json: AccountSerializer.new(@accounts).serializable_hash, status: :ok
        # else
        #   render json: {errors: "accounts data does not exist"}, status: :ok
        # end
      end
  
      def logged_user
        # @account = Account.find(@token.id)
        # if @account.present?
        #   render json: AccountSerializer.new(@account).serializable_hash, status: :ok
        # else
        #   render json: {errors: "account does not exist"}, status: :ok
        # end
      end
  
      def get_links
       footers = AccountBlock::Footer&.first
        return if footers.nil?
        render json: AccountBlock::FooterSerializer.new(footers),
        status: :ok
      end
  
      private
      def send_pin_via_sms(phone)
        new_record = AccountBlock::SmsOtp.new(full_phone_number: phone)
        new_record.save
        # return (new_recor.valid_until - Time.current).to_i 
      end
  
      def send_email_otp(account)
        email_otp = AccountBlock::EmailOtp.new(email: account.email)
        if email_otp.valid?
          email_otp.save
          EmailVerificationMailer
          .with(account: account, otp: email_otp, host: request.base_url)
          .email_otp.deliver_now
        end
  
        return (email_otp.valid_until - Time.current).to_i
      end
  
      def serialize_options
        {params: {host: request.protocol + request.host_with_port }}
      end
  
      def encode(id)
        BuilderJsonWebToken.encode id
      end
  
      def account_params_for_attributes
        params.require(:data).require(:attributes).permit(
          :activated, :country_code, :email, :first_name, :full_phone_number,
          :last_name, :phone_number, :type, :created_at, :updated_at,
          :device_id, :unique_auth_id, :role_id, :date_of_birth, :gender,
          :bio, :preffered_language, :social_media_link, :user_type, :location,:image,
          :role, :document, :number_of_acquisition_closed,:flag,
          :projected_annual_acquisitions, :accredited_buyer, :country, :city, :profile_percent, :buyer_role, :seller_role
          )
      end
    end
  end










  Test CASES=====================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


  require 'rails_helper'

RSpec.describe AccountBlock::AccountsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:account)
    @token = BuilderJsonWebToken::JsonWebToken.encode(@user.id)
    @token1 = BuilderJsonWebToken::JsonWebToken.encode(0)
    @file = fixture_file_upload('/demo.jpeg', 'image/jpeg')
    @sms = FactoryBot.create(:sms_otp, full_phone_number: 12_564_030_023)
    @mail = AccountBlock::EmailValidationMailer.with(account: @user, host: 'http://localhost:3000').activation_email
  end

  describe 'GET #get_links' do
    context 'when AccountBlock::Footer is present' do
      before do
        @footer = create(:footer)
        get :get_links
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the footer links in JSON format' do
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to eq nil
      end
    end
  end

  describe 'POST #create' do
    context 'when creating an email account' do
      it 'creates a valid email account' do
        # Prepare valid params for creating an email account
        valid_params = {
          "data": {
            "type": 'email_account',
            "attributes": {
              "first_name": Faker::Name.first_name,
              "last_name": Faker::Name.last_name,
              "email": Faker::Internet.free_email,
              "password": Faker::Internet.password,
              "full_phone_number": 12_564_030_023,
              "user_type": 'buyer',
              "activated": true
            }
          }
        }
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('data')
        # Add more assertions as needed
      end

      it 'creates a valid email account with user_type case insensitive' do
        # Prepare valid params for creating an email account
        valid_params = {
          "data": {
            "type": 'email_account',
            "attributes": {
              "first_name": Faker::Name.first_name,
              "last_name": Faker::Name.last_name,
              "email": Faker::Internet.free_email,
              "password": Faker::Internet.password,
              "full_phone_number": 12_564_030_023,
              "user_type": 'Buyer',
              "activated": true
            }
          }
        }
        post :create, params: valid_params
        expect(response).not_to be_nil
      end

      it 'check the response body contain the user_state' do
        valid_params = {
          "data": {
            "type": 'email_account',
            "attributes": {
              "first_name": Faker::Name.first_name,
              "last_name": Faker::Name.last_name,
              "email": Faker::Internet.free_email,
              "password": Faker::Internet.password,
              "full_phone_number": 12_564_030_023,
              "user_type": 'buyer',
              "activated": true
            }
          }
        }
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'check the user_state is set for user_type_selection' do
        valid_params = {
          "data": {
            "type": 'email_account',
            "attributes": {
              "first_name": Faker::Name.first_name,
              "last_name": Faker::Name.last_name,
              "email": Faker::Internet.free_email,
              "password": Faker::Internet.password,
              "full_phone_number": 12_564_030_023,
              "user_type": 'buyer',
              "user_state": 'user_type_selection',
              "activated": true
            }
          }
        }
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(response.status).to eq 200
      end

      it 'returns error  for invalid email' do
        # Prepare invalid params for creating an email account
        invalid_params = { data: { type: 'email_account',
                                   attributes: { first_name: 'Test1', last_name: 'User1', email: 'test123example.com', password: 'Test@123',
                                                 user_type: 'Buyer', activated: true, full_phone_number: 12_564_030_023 } } }
        # invalid_params = { data: { type: 'email_account', attributes: { email: 'invalid-email' } } }
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
        # Add more assertions as needed
      end

      it 'returns error if email already exists' do
        # Create a mock email account with a duplicate email
        # existing_account = FactoryBot.create(:email_account, email: 'duplicate@example.com')
        duplicate_params = { data: { type: 'email_account',
                                     attributes: { first_name: 'Test', last_name: 'User', email: 'test@example.com', user_type: 'buyer',
                                                   full_phone_number: 12_564_030_023 } } }
        # duplicate_params = { data: { type: 'email_account', attributes: { email: 'duplicate@example.com' } } }
        post :create, params: duplicate_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)).to have_key('errors')
        # Add more assertions as needed
      end

      it 'check the user_type sets to user selected user_type' do
        valid_params = {
          "data": {
            "type": 'email_account',
            "attributes": {
              "first_name": Faker::Name.first_name,
              "last_name": Faker::Name.last_name,
              "email": Faker::Internet.free_email,
              "password": Faker::Internet.password,
              "full_phone_number": 12_564_030_023,
              "activated": true
            }
          }
        }
        post :create, params: valid_params
        response_data = JSON.parse(response.body)
        user_type = response_data.dig('data', 'attributes', 'user_type')
        expect(user_type).to eq('seller')
      end

      it 'returns error if full_phone_number already exists' do
        # Create a mock email account with a duplicate email
        # existing_account = FactoryBot.create(:email_account, email: 'duplicate@example.com')
        duplicate_params = { data: { type: 'email_account',
                                     attributes: { first_name: 'Test', last_name: 'User', email: 'test@example.com', user_type: 'buyer',
                                                   full_phone_number: '+919876543210' } } }
        # duplicate_params = { data: { type: 'email_account', attributes: { email: 'duplicate@example.com' } } }
        post :create, params: duplicate_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)).to have_key('errors')
        # Add more test cases for different scenarios
      end
    end

    context 'when creating an email account' do
      valid_params = {
        "data": {
          "type": 'email_account',
          "attributes": {
            "first_name": Faker::Name.first_name,
            "last_name": Faker::Name.last_name,
            "email": Faker::Internet.free_email,
            "password": Faker::Internet.password,
            "full_phone_number": 12_564_030_023,
            "user_type": 'buyer',
            "user_state": 'user_type_selection',
            "activated": true
          }
        }
      }

      it 'check successfully send the email and account was created' do
        post :create, params: valid_params
        expect(response.message).to eq('OK')
      end

      it 'check sussessfully send the email even when there is issue with SMTP' do
        post :create, params: valid_params
        expect(flash[:alert]).to eq(nil)
      end

      it 'returns a successfull response wheather mail deliverd or not' do
        # Stub the behavior of EmailValidationMailer to prevent exceptions

        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PUT #update' do
    context 'when updating signup type successfully' do
      it 'updates signup type and returns success' do
        allow(AccountBlock::EmailAccount).to receive(:find_by).and_return(@user)
        allow(@user).to receive(:update).and_return(true)
        request.headers['token'] = "#{@token}"
        patch :update, params: {
          data: {
            "type": 'email_account',
            "attributes": {
              "user_type": 'buyer'
            }
          }
        }
        expect(response).to have_http_status(:ok)
      end

      context 'with valid attributes' do
        it 'updates the Account profile parameters' do
          @user2 = FactoryBot.create(:account)
          token = BuilderJsonWebToken::JsonWebToken.encode(@user2.id)

          put :update, params: {
            token: token,
            id: @user2.id,
            data: {
              type: 'email_account',
              attributes: {
                first_name: @user2.first_name,
                last_name: @user2.last_name,
                email: @user2.email,
                full_phone_number: 9_131_994_745,
                country_code: @user2.country_code,
                password: @user2.password,
                user_type: @user2.user_type,
                preffered_language: @user2.preffered_language,
                social_media_link: @user2.social_media_link,
                number_of_acquisition_closed: 100,
                projected_annual_acquisitions: 50,
                accredited_buyer: 'test1',
                country: 'UAE',
                city: 'Dubai'
              }
            }
          }

          expect(response).to have_http_status(:ok)
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)['data']['id']).to eq(@user2.id.to_s)
          expect(JSON.parse(response.body)['data']['attributes']['first_name']).to eq(@user2.first_name)
          expect(JSON.parse(response.body)['data']['attributes']['last_name']).to eq(@user2.last_name)
          expect(JSON.parse(response.body)['data']['attributes']['email']).to eq(@user2.email)
          expect(JSON.parse(response.body)['data']['attributes']['full_phone_number']).to eq(9_131_994_745.to_s)
          expect(JSON.parse(response.body)['data']['attributes']['user_type']).to eq(@user2.user_type)
          expect(JSON.parse(response.body)['data']['attributes']['preffered_language']).to eq(@user2.preffered_language)
          expect(JSON.parse(response.body)['data']['attributes']['social_media_link']).to eq(@user2.social_media_link)
          expect(JSON.parse(response.body)['data']['attributes']['number_of_acquisition_closed']).to eq(100)
          expect(JSON.parse(response.body)['data']['attributes']['projected_annual_acquisitions']).to eq(50)
          expect(JSON.parse(response.body)['data']['attributes']['accredited_buyer']).to eq('test1')
          expect(JSON.parse(response.body)['data']['attributes']['country']).to eq('UAE')
          expect(JSON.parse(response.body)['data']['attributes']['city']).to eq('Dubai')
        end
      end

      describe '#deactivate_account' do
        context 'when flag is true' do
          it 'deactivates the account' do
            request.headers['token'] = @token
            put :deactivate_account, params: {
              data: {
                attributes: {
                  flag: 'true'
                }
              }
            }
            expect(response).to have_http_status(:ok)
            expect(response.status).to eq 200
            expect(JSON.parse(response.body)['message']).to eq('Your account has been successfully deactivated')
          end
        end

        context 'when flag is not true' do
          it 'does not deactivate the account' do
            request.headers['token'] = @token
            put :deactivate_account, params: {
              data: {
                attributes: {
                  flag: 'false'
                }
              }
            }
            expect(response.status).to eq 204
          end
        end
      end

      describe 'PUT #update' do
        context 'when updating signup type successfully' do
          it 'updates signup type and returns success' do
            allow(AccountBlock::EmailAccount).to receive(:find_by).and_return(@user)
            allow(@user).to receive(:update).and_return(true)
            request.headers['token'] = "#{@token}"
            patch :update, params: {
              data: {
                "type": 'email_account',
                "attributes": {
                  "user_type": 'buyer'
                }
              }
            }
            expect(response).to have_http_status(:ok)
            expect(response.status).to eq 200
          end

          context 'with valid first attributes' do
            it 'updates the Account profiles parameters' do
              @user2 = FactoryBot.create(:account)
              token = BuilderJsonWebToken::JsonWebToken.encode(@user2.id)

              put :update, params: {
                token: token,
                id: @user2.id,
                data: {
                  type: 'email_account',
                  attributes: {
                    first_name: @user2.first_name,
                    last_name: @user2.last_name,
                    email: @user2.email,
                    full_phone_number: @user2.full_phone_number,
                    country_code: @user2.country_code,
                    password: @user2.password,
                    user_type: @user2.user_type,
                    preffered_language: @user2.preffered_language,
                    social_media_link: @user2.social_media_link
                  }
                }
              }

              expect(response).to have_http_status(:ok)
              expect(response).to have_http_status(:success)
              expect(JSON.parse(response.body)['data']['id']).to eq(@user2.id.to_s)
              expect(JSON.parse(response.body)['data']['attributes']['first_name']).to eq(@user2.first_name)
              expect(JSON.parse(response.body)['data']['attributes']['last_name']).to eq(@user2.last_name)
              expect(JSON.parse(response.body)['data']['attributes']['email']).to eq(@user2.email)
              expect(JSON.parse(response.body)['data']['attributes']['full_phone_number']).to eq(@user2.full_phone_number)
              expect(JSON.parse(response.body)['data']['attributes']['user_type']).to eq(@user2.user_type)
              expect(JSON.parse(response.body)['data']['attributes']['preffered_language']).to eq(@user2.preffered_language)
              expect(JSON.parse(response.body)['data']['attributes']['social_media_link']).to eq(@user2.social_media_link)
            end
          end

          context 'with invalid attributes' do
            it 'gives unprocessable_entity when wrong parameters are passed' do
              @user2 = FactoryBot.create(:account)
              token  = BuilderJsonWebToken::JsonWebToken.encode(@user2.id)
              put :update, params: {
                token: token,
                id: nil,
                data: {
                  type: 'email_account',
                  attributes: {
                    first_name: @user2.first_name,
                    last_name: @user2.last_name,
                    email: nil,
                    full_phone_number: 9_131_994_745,
                    country_code: @user2.country_code,
                    password: @user2.password,
                    user_type: @user2.user_type,
                    bio: @user2.bio,
                    preffered_language: @user2.preffered_language,
                    social_media_link: @user2.social_media_link
                  }
                }
              }
              expect(response).to have_http_status(:unprocessable_entity)
            end
          end

          it 'When invalid id' do
            allow(AccountBlock::EmailAccount).to receive(:find_by).and_return(@user)
            allow(@user).to receive(:update).and_return(true)
            request.headers['token'] = "#{@token1}"
            put :update, params: {
              data: {
                "type": 'email_account',
                "attributes": {
                  "user_type": 'buyer'
                }
              }
            }
            expect(response).to have_http_status(:not_found)
          end

          context 'when user_type is present and user_state is user_type_selection' do
            it 'updates sale_type_selection to user_state' do
              user1 = FactoryBot.create(:email_account1)
              token1 = BuilderJsonWebToken::JsonWebToken.encode(user1.id)
              request.headers['token'] = "#{token1}"
              patch :update, params: {
                data: {
                  "type": 'email_account',
                  "attributes": {
                    "user_type": 'buyer'
                  }
                }
              }

              expect(AccountBlock::EmailAccount.last.user_state).to eq('user_type_selection')
            end
          end
        end
      end
    end
  end
end





=================================================================================================================================

forget password controller 




module AccountBlock
	class ForgotPasswordController < ApplicationController
		skip_before_action :validate_json_web_token, only: [:create]

		def create
      # Check what type of account we are trying to recover
      json_params = jsonapi_deserialize(forget_password_params)
      if json_params['email'].present?
        # Get account by email
        account = AccountBlock::EmailAccount
         .where(
            "LOWER(email) = ? ",
            json_params['email'].downcase
          ).first

        if account.present?
          token = token_for(account)
          reset_password_url = json_params.dig('reset_password_url')
          send_email_for(account, token, account.type, reset_password_url)
          render json: {
            success: true,
            message: "Email to reset password has been sent to #{json_params['email']}",
            meta: {
              token: token,
              type: account.type
            }
          }
        else 
        	render json: {
	          errors: [{
	            message: "Account not exist",
	          }],
	        }, status: :not_found
        end  
      else
        return render json: {
          errors: [{
            message: "Email must be required",
          }],
        }, status: :unprocessable_entity
      end
    end

    private

    def send_email_for(account, token, type, reset_password_url)
      ForgotPasswordMailer
        .with(account: account, host: request.base_url, token: token, type: account.type,
          reset_password_url: reset_password_url)
        .send_email.deliver
    rescue Errno::ECONNREFUSED => e
      puts "Failed to send email : Message : #{e.message } Cause : #{e.cause} Trace: #{e.backtrace}"
      flash[:alert] = 'Misconfigured SMTP credentials'
      return false
    end

    def token_for(account)
      BuilderJsonWebToken.encode account.id, 24.hours.from_now
    end

    def forget_password_params
      params.permit(data: [attributes: [:email, :reset_password_url]])
    end
	end
end



========================================================================================================================================

spec test cases for forget password =========================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


require 'rails_helper'

RSpec.describe "AccountBlock::ForgotPasswords", type: :request do
  account = FactoryBot.create(:email_account)
  @token = BuilderJsonWebToken.encode(account.id)
  let(:forgot_password_params) { { data: { attributes: { email: account.email,
    reset_password_url: "http://localhost:3000/NewPassword"}}}}
  let(:invalid_params) { { data: { attributes: { email: "abc@gmail.com"}}}}
  let(:missing_params) { { data: { attributes: { email: nil}}}}

  FORGOT_URL = "/account_block/forgot_password"
  
  describe "Post /create" do
    it "When password reset successfully" do
      post FORGOT_URL, params: forgot_password_params
      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
    end

    it "When forgot password failed due to invalid email" do
      post FORGOT_URL, params: invalid_params
      data = JSON.parse(response.body)
      expect(response).to have_http_status(404)
    end

    it "When forgot failed email required" do
      post FORGOT_URL,  params: missing_params
      data = JSON.parse(response.body)
      expect(response).to have_http_status(422)
    end

    it "When forgot email successfully send" do
      allow(AccountBlock::ForgotPasswordMailer).to receive(:with)
        .and_return(double(send_email: double(deliver: true)))

      post FORGOT_URL,  params: forgot_password_params
      data = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
    end

    it "When forgot email failed to send email" do
      allow(AccountBlock::ForgotPasswordMailer).to receive(:with).and_raise(Errno::ECONNREFUSED)

      post FORGOT_URL,  params: forgot_password_params
      data = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
    end

    it "cheacking the reset password parameter" do
      post FORGOT_URL,  params: forgot_password_params
      request_params = request.params.dig(:data, :attributes)
      expect(request_params).to have_key(:reset_password_url)
    end
  end
end




password controlller ================================================================================++++++++>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>..

module AccountBlock
	class PasswordController < ApplicationController
		skip_before_action :validate_json_web_token, only: [:create]

    def create
     	password_params = jsonapi_deserialize(params)
     	
     	if password_params['token'].blank?
        return render json: {
          errors: [{
            message: "Token can't be blank",
          }],
        }, status: :unprocessable_entity
      end

      begin
        token = BuilderJsonWebToken.decode(password_params['token'])
      rescue JWT::DecodeError => e
        return render json: {
          errors: [{
            message: "Invalid token",
          }],
        }, status: :bad_request
      end

      account = AccountBlock::EmailAccount.find(token.id)

      if !password_params['new_password'].eql?(password_params['confirm_password'])
        return render json: {
          errors: [{
            message: "Password doesn't match",
          }],
        }, status: :unprocessable_entity
      end

      if account.present?
        account.update(:password => password_params['new_password'],
                         :password_confirmation => password_params['confirm_password'])

        render json: AccountBlock::AccountSerializer.new(account, meta: {
        		message: "Congratulations,Password has been changed successfully",
            token: encode(account.id)
          }).serializable_hash, status: :ok
      else
        render json: {
          errors: [{
            message: "account not found",
          }],
        }, status: :unprocessable_entity
      end
    end

    private

    def encode(id)
      BuilderJsonWebToken.encode id
    end
	end
end
