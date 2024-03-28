

in gemfile
    gem 'twilio-ruby'

in developement.rb and in production.rb
config.x.sms.provider = :twilio
config.x.sms.account_id = ENV['SMS_ACCOUNT_ID']
config.x.sms.auth_token = ENV['SMS_AUTH_TOKEN']
config.x.sms.from = ENV['SMS_FROM']



whole twilio example from builder ... 

accounts controller =====================================================================================================================================


module AccountBlock
    class AccountsController < ApplicationController
     include BuilderJsonWebToken::JsonWebTokenValidation
  
     EMAIL_ERROR = "Email already registered and activated"
  
     before_action :validate_json_web_token, only: [:search, :change_email_address, :change_phone_number, :specific_account, :logged_user, :update ,:deactivate_account, :show]
     before_action :current_user, only: %i[update deactivate_account show]
  
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
            # email_otp_timer = send_email_otp(@account)
            send_pin_via_sms(phone_number)
            # mobile_otp_timer = send_pin_via_sms(phone_number)
            BxBlockNotifications::NotificationCreator.new(@account, "Signup Notification", "Hello #{@account.first_name} you've been successfully Signed Up", @account.id).call
            return render json: EmailAccountSerializer.new(@account, meta: {
              # email_otp_timer: email_otp_timer,
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
  
      def show
        account = @current_user
        render json: AccountSerializer.new(account, serialize_options).serializable_hash, status: 200
      end
  
      private
      def send_pin_via_sms(phone)
        pin = "1234"
        new_record = AccountBlock::SmsOtp.new(full_phone_number: phone, pin: "1234")
        message = "Your verification code is #{pin}."
        credentials = {api_key: 'xYMmWva1sHImWYh7infHhpwSRcUIvr', sender_name: "EjariSMS"}
        # sender_id = "EjariSMS" # Replace with your desired sender ID
        # result = Unifonic::SMS.send(   phone, message , sender_id)
        # response = HsUnifonic.send_sms {to: phone, message: 'Hello from hs_unifonic!', sender_id: sender_id, message: message}
        # debugger
       # response = HsUnifonic.send_sms(credentials, phone, 'Hello from hs_unifonic!', sender_id)
  # debugger
       # response = UnifonicSms.send_message(   "917972349463", message , sender_id)
       # debugger
        
  
  # HsUnifonic.send_sms(credentials, mobile_number, message,sender,options)
  
      
        new_record.save
        # return (new_recor.valid_until - Time.current).to_i 
      end
  
  # def send_pin_via_sms(phone)
  # credentials = {
  #   api_key: 'xYMmWva1sHImWYh7infHhpwSRcUIvr',
  #   sender_name: 'EjariSMS'
  # }
  # phone = "9660564726771"
  # # Set up a Faraday connection to the Unifonic API endpoint
  # connection = Faraday.new(url: 'https://api.unifonic.com') do |faraday|
  #   faraday.request :json
  #   faraday.response :json, content_type: /\bjson$/
  #   faraday.adapter Faraday.default_adapter
  # end
  
  # # Define the message parameters
  # message_params = {
  #   to: phone,    # Replace 'RECIPIENT_NUMBER' with the recipient's phone number
  #   body: 'Hello from hs_unifonic!',
  #   sender_id: 'EjariSMS'      # Replace 'EjariSMS' with your desired sender ID
  # }
  
  # # Make a POST request to the Unifonic API to send the message
  # response = connection.post('/rest/send') do |req|
  #   req.headers['Content-Type'] = 'application/json'
  #   req.body = credentials.merge(message_params).to_json
  # end
  
  # # Output the response from the Unifonic API
  # debugger
  # puts response.body
  # end
  
  
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


   ===============================================================================================================================================
step 2 

module AccountBlock
    class SmsOtp < ApplicationRecord
      self.table_name = :sms_otps
  
      include Wisper::Publisher
  
      after_create :invalidate_old_mobile_otp
  
      before_validation :parse_full_phone_number
  
      before_create :generate_pin_and_valid_date
      after_create :send_pin_via_sms
  
      # validate :valid_phone_number
      validates :full_phone_number, presence: true
  
      attr_reader :phone
  
      def generate_pin_and_valid_date
        self.pin = rand(1_000..9_999)
        self.valid_until = Time.current + 5.minutes
      end
  
      def expired?
        valid_until < Time.current
      end
  
      def send_pin_via_sms
        unless Rails.env == 'test'
          trigger_send_pin
        end
      end
  
      private
  
    def trigger_send_pin
    begin
      message = "Your Pin Number is #{pin}"
      txt = BxBlockSms::SendSms.new("+#{full_phone_number}", message)
      txt.call
    rescue Twilio::REST::RestError
      100.times { puts "a" }
      return true
    end
  end
  
  
      def parse_full_phone_number
        @phone = Phonelib.parse(full_phone_number)
        self.full_phone_number = @phone.sanitized
      end
  
      def invalidate_old_mobile_otp
        # Find all unactivated OTPs for all accounts
        AccountBlock::SmsOtp.where(full_phone_number: full_phone_number, activated: false)
          .where.not(id: id).update_all(valid_until: Time.now - 5.minutes)
      end
  
      def valid_phone_number
        unless Phonelib.valid?(full_phone_number)
          errors.add(:full_phone_number, "Invalid or Unrecognized Phone Number")
        end
      end
    end
  end
=====================================================================================================================================================

STEP 3 


module BxBlockSms
  class SendSms
    attr_reader :to, :text_content

    def initialize(to, text_content)
      @to = to
      @text_content = text_content
    end

    def call
      Provider.send_sms(to, text_content)
    end
  end
end
======================================================================================================================================================

STEP 4 
in service/ provider.rb
module BxBlockSms
    class Provider
      TWILIO = :twilio.freeze
      KARIX = :karix.freeze
      TEST = :test.freeze
  
      SUPPORTED = [TWILIO, KARIX, TEST].freeze
  
      class << self
        def send_sms(to, text_content)
          provider_klass = case provider_name
                           when TWILIO
                             Providers::Twilio
                           when KARIX
                             Providers::Karix
                           when TEST
                             Providers::Test
                           else
                             raise unsupported_message(provider_name)
                           end
  debugger
          provider_klass.send_sms(to, text_content)
        end
  
        def provider_name
          Rails.configuration.x.sms.provider
        end
  
        def unsupported_message(provider)
          supported_prov_msg = "Supported: #{SUPPORTED.join(", ")}."
          if provider
            "Unsupported SMS provider: #{provider}. #{supported_prov_msg}"
          else
            "You must specify a SMS provider. #{supported_prov_msg}"
          end
        end
      end
    end
  end

  ==========================================================================================================================
in service/providers/twilio.rb    ============= this is for twilio
  module BxBlockSms
    module Providers
      class Twilio
        class << self
          def send_sms(full_phone_number, text_content)
            client = ::Twilio::REST::Client.new(account_id, auth_token)
            client.messages.create({
                                     from: from,
                                     to: full_phone_number,
                                     body: text_content
                                   })
          end
  
          def account_id
            Rails.configuration.x.sms.account_id
          end
  
          def auth_token
            Rails.configuration.x.sms.auth_token
          end
  
          def from
            Rails.configuration.x.sms.from
          end
        end
      end
    end
  end
  
for unifonic you can use like ====================================================================================
  
# lib/bx_block_sms/providers/unifonic.rb
module BxBlockSms
  module Providers
    class Unifonic
      BASE_URL = 'https://api.unifonic.com/rest'.freeze

      class << self
        def send_sms(to, text_content)
          params = {
            recipient: to,
            body: text_content,
            sender: Rails.configuration.x.sms.sender_id,
            apiKey: Rails.configuration.x.sms.api_key
          }

          response = HTTParty.post("#{BASE_URL}/Messages/Send", body: params)
          response.code == 200 ? true : false
        end
      end
    end
  end
end

  =====================================================================================================

  and above configuration in gemfile/developement/production.rb

  twilio working creds 

  config.x.sms.provider = :twilio
  config.x.sms.account_id = "ACfc35c9a78deb10715ddf75faaa216438"
  config.x.sms.auth_token = "c8dd9c0fe45cc7666db717ac85f1d82a"
  config.x.sms.from = "+12678734329"

# to=> "+917972349463"  this is for testing  purpose only



