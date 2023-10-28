
module AccountBlock
    # app/models/account_block/account.rb
    class Account < AccountBlock::ApplicationRecord
      self.table_name = :accounts
      acts_as_paranoid
      attr_accessor :admin
  ​
      include Wisper::Publisher
      has_secure_password validations: false
      validate :check_password_format, on: :create, if: :user_created_by_admin?
      before_create :generate_api_key
      has_one :blacklist_user, class_name: 'AccountBlock::BlackListUser', dependent: :destroy
      has_one :cart, class_name: 'BxBlockCart::Cart'
      has_one :wishlist, class_name: 'BxBlockWishlist2::Wishlist'
      has_many :addresses, class_name: 'BxBlockAddress::Address', dependent: :destroy
      has_many :notifications, class_name: 'BxBlockNotifications::Notification', dependent: :destroy
      has_many :cards, class_name: 'CardBlock::Card', dependent: :destroy
      has_many :orders, class_name: 'OrderBx::Order', dependent: :destroy
      has_many :contacts, class_name: 'BxBlockContactUs::Contact', dependent: :destroy
      has_one_attached :profile_photo
      has_one_attached :cover_photo
      enum status: %i[regular suspended deleted]
  ​
      scope :active, -> { where(activated: true) }
      scope :existing_accounts, -> { where(status: %w[regular suspended]) }
  ​
      def user_created_by_admin?
        admin.present? && admin == 'yes'
      end
  ​
      def check_password_format
        password = self.password
        if password.present?
          if password&.count('0-9').positive? && password&.length > 5 && password&.match(/[A-Z]/).present?
            true
          else
            errors.add(:password, 'incorrect format ')
          end
        else
          errors.add(:password, ' password cant be blank ')
        end
      end
  ​
      def profile_image(base_url = nil)
        return unless profile_photo.present?
  ​
        image_path = Rails.application.routes.url_helpers.rails_blob_path(profile_photo, only_path: true)
        "#{base_url}#{image_path}"
      end
  ​
      def cover_image(base_url = nil)
        return unless cover_photo.present?
  ​
        image_path = Rails.application.routes.url_helpers.rails_blob_path(cover_photo, only_path: true)
        "#{base_url}#{image_path}"
      end
  ​
      private
  ​
      def generate_api_key
        loop do
          @token = SecureRandom.base64.tr('+/=', 'Qrt')
          break @token unless Account.exists?(unique_auth_id: @token)
        end
        self.unique_auth_id = @token
      end
    end
  end