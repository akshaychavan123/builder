
Account Model ==============================================================================================================================================

require 'aasm'

module AccountBlock
  class Account < AccountBlock::ApplicationRecord
    ActiveSupport.run_load_hooks(:account, self)
    self.table_name = :accounts
    include Wisper::Publisher
    include AASM
    TAKEN_ERROR = "has already been taken"
    has_secure_password
    before_validation :parse_full_phone_number
    before_create :generate_api_key
    has_many :access_requests, class_name: 'AccountBlock::AccessRequest', foreign_key: 'buyer_id'
    has_one :blacklist_user, class_name: "AccountBlock::BlackListUser", dependent: :destroy
    # has_one :summarry, class_name: "BxBlockProfile::Summarry", dependent: :destroy
    has_many :listings, class_name: "BxBlockCatalogue::Listing", dependent: :destroy
    has_many :catalogues, class_name: "BxBlockCatalogue::Catalogue", dependent: :destroy
    accepts_nested_attributes_for :catalogues, allow_destroy: true
    has_many :user_subscription_plans, class_name: 'BxBlockSubscriptions::UserSubscriptionPlan', dependent: :destroy
    has_many :subscription_plans, through: :user_subscription_plans
    has_many :feature_benefits, through: :subscription_plans
    has_many :user_archieved_catalogues,class_name: "BxBlockCatalogue::UserArchievedCatalogue", dependent: :destroy
    # has_one :business_customer_vendor_metric, class_name: "BxBlockProfile::BusinessCustomerVendorMetric", dependent: :destroy
    # has_one :business_financial, class_name: "BxBlockProfile::BusinessFinancial", dependent: :destroy
    # has_one :business_acquisition_detail, class_name: "BxBlockProfile::BusinessAcquisitionDetail", dependent: :destroy
    # has_one :private_business_information, class_name: "BxBlockProfile::PrivateBusinessInformation", dependent: :destroy
    # has_one :acquisition_detail, class_name: "BxBlockProfile::AcquisitionDetail", dependent: :destroy
    # has_one :customer_metric, class_name: "BxBlockProfile::CustomerMetric", dependent: :destroy
    # has_one :business_company_overview, class_name: "BxBlockProfile::BusinessCompanyOverview", dependent: :destroy
    # has_one :private_information, class_name: "BxBlockProfile::PrivateInformation", dependent: :destroy
    # has_many :list_of_products, class_name: "BxBlockProfile::ListOfProduct", dependent: :destroy
    # has_one :financial, class_name: "BxBlockProfile::Financial", dependent: :destroy
    has_many :catalogue_lists, class_name: "BxBlockCatalogue::CatalogueList", dependent: :destroy
    has_many :bookmark_catalogues, class_name: "BxBlockCatalogue::BookmarkCatalogue", dependent: :destroy
    has_many :need_helps, class_name: "BxBlockContactUs::NeedHelp", dependent: :destroy
    after_save :set_black_listed_user
    has_one_attached :image
    has_one_attached :document
    enum preffered_language: { english: '0', arabic: '1'}
    enum status: %i[regular suspended deleted]
    enum user_type: { buyer: '0', seller: '1', financial_and_legal_advisors: '2' }
    enum buyer_role: { private_equity: 0, venture_capital: 1, family_office: 2, high_net_worth_individual: 3, executive: 4, employee_at_company: 5, entrepreneur: 6, other_buyer_type: 7 }
    enum seller_role: { founder_entrepreneur: 0, engineer: 1, operator: 2, marketer: 3,
    broker: 4, other_seller_type: 5 }
    enum user_state: { account_created: 0, user_type_selection: 1, sale_type_selection: 2,
     business_type_selection: 3}
    enum seller_role: { founder_entrepreneur: 0, engineer: 1, operator: 2, 
      marketer: 3, broker: 4, other: 5 }, _prefix: true
    enum buyer_role: { private_equity: 0, venture_capital: 1, family_office: 2, 
      high_net_worth_individual: 3, executive: 4, employee_at_company: 5, 
      entrepreneur: 6, other: 7 }, _prefix: true

  validate :password_does_not_contain_name_or_email
  scope :active, -> { where(activated: true) }
  scope :existing_accounts, -> { where(status: ["regular", "suspended"]) }

  validates :email, uniqueness: { message: TAKEN_ERROR }, presence: true
  validates :full_phone_number, uniqueness: { message: TAKEN_ERROR }, presence: true

  aasm column: 'user_state', enum: true do
    state :account_created, initial: true
    state :user_type_selection
    state :sale_type_selection
    state :business_type_selection

    event :set_to_user_type do
      transitions from: [:account_created], to: :user_type_selection
    end
    event :set_to_sale_type do
      transitions from: [:user_type_selection], to: :sale_type_selection
    end

    event :set_to_company_type do
      transitions from: [:sale_type_selection], to: :business_type_selection
    end
  end

  def password_does_not_contain_name_or_email
    if self.password.present? && (self.password.downcase.include?(self.first_name.downcase) || self.password.downcase.include?(self.last_name.downcase) || self.password.downcase.include?(self.email.downcase))
      errors.add(:password, "cannot contain your first name, last name, or email.")
    end
  end

  def errors
    super.tap do |errors|
      errors[:email].map! { |message| custom_message_for(:email, message) } if errors[:email].present?
      errors[:full_phone_number].map! { |message| custom_message_for(:full_phone_number, message) } if errors[:full_phone_number].present?
    end
  end

  def mobile_otp
    AccountBlock::SmsOtp.where(full_phone_number: self.full_phone_number).order(id: :DESC).first&.pin
  end

  private
  def custom_message_for(attribute, message)
    case [attribute, message]
    when [:email, TAKEN_ERROR]
      "Email ID already registered"
    when [:full_phone_number, TAKEN_ERROR]
      "Phone Number already registered"
    else
      message
    end
  end

  private

  def parse_full_phone_number
    phone = Phonelib.parse(full_phone_number)
    self.full_phone_number = phone.sanitized
    self.country_code = phone.country_code
    self.phone_number = phone.raw_national
  end

  def valid_phone_number
    unless Phonelib.valid?(full_phone_number)
      errors.add(:full_phone_number, "Invalid or Unrecognized Phone Number")
    end
  end

  def generate_api_key
    loop do
      @token = SecureRandom.base64.tr("+/=", "Qrt")
      break @token unless Account.exists?(unique_auth_id: @token)
    end
    self.unique_auth_id = @token
  end

  def set_black_listed_user
    if is_blacklisted_previously_changed?
      if is_blacklisted
        AccountBlock::BlackListUser.create(account_id: id)
      else
        blacklist_user.destroy
      end
    end
  end
end
end



================================================================================================================================================

Accont Controllere

================================================================================================================================================
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