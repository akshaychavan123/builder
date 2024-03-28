unifonic_sms
 
RUBY VERSION
   ruby 2.6.5p114

BUNDLED WITH
-   2.4.18
+   2.4.12
diff --git a/template-app/app/services/bx_block_sms/provider.rb b/template-app/app/services/bx_block_sms/provider.rb
index a8b107b..12f0c05 100644
--- a/template-app/app/services/bx_block_sms/provider.rb
+++ b/template-app/app/services/bx_block_sms/provider.rb
@@ -15,6 +15,8 @@ module BxBlockSms
                           Providers::Karix
                         when TEST
                           Providers::Test
+                          when UNIFONIC
+                           Providers::Unifonic
                         else
                           raise unsupported_message(provider_name)
                         end
diff --git a/template-app/app/services/bx_block_sms/providers/unifonic.rb b/template-app/app/services/bx_block_sms/providers/unifonic.rb
new file mode 100644
index 0000000..8e483ec
--- /dev/null
+++ b/template-app/app/services/bx_block_sms/providers/unifonic.rb
@@ -0,0 +1,21 @@
+module BxBlockSms
+  module Providers
+    class Unifonic
+      BASE_URL = 'https://api.unifonic.com/rest'.freeze
+
+      class << self
+        def send_sms(to, text_content)
+          params = {
+            recipient: to,
+            body: text_content,
+            sender: Rails.configuration.x.sms.sender_id,
+            apiKey: Rails.configuration.x.sms.api_key
+          }
+
+          response = HTTParty.post("#{BASE_URL}/Messages/Send", body: params)
+          response.code == 200 ? true : false
+        end
+      end
+    end
+  end
+end
diff --git a/template-app/config/environments/development.rb b/template-app/config/environments/development.rb
index 821f9ef..ff2a047 100644
--- a/template-app/config/environments/development.rb
+++ b/template-app/config/environments/development.rb
@@ -67,8 +67,7 @@ Rails.application.configure do
    open_timeout:         5,
    read_timeout:         5 
  }
-  config.x.sms.provider = :twilio
-  config.x.sms.account_id = ENV['SMS_ACCOUNT_ID']
-  config.x.sms.auth_token = ENV['SMS_AUTH_TOKEN']
-  config.x.sms.from = ENV['SMS_FROM']
+  config.x.sms.provider = :unifonic
+  config.x.sms.api_key = ENV['UNIFONIC_API_KEY']
+  config.x.sms.sender_id = ENV['UNIFONIC_SENDER_ID']
end
diff --git a/template-app/config/environments/production.rb b/template-app/config/environments/production.rb
index 80665be..df9f166 100644
--- a/template-app/config/environments/production.rb
+++ b/template-app/config/environments/production.rb
@@ -114,8 +114,7 @@ Rails.application.configure do
    read_timeout:         5 
  }

-  config.x.sms.provider = :twilio
-  config.x.sms.account_id = ENV['SMS_ACCOUNT_ID']
-  config.x.sms.auth_token = ENV['SMS_AUTH_TOKEN']
-  config.x.sms.from = ENV['SMS_FROM']
+  config.x.sms.provider = :unifonic
+  config.x.sms.api_key = ENV['UNIFONIC_API_KEY']
+  config.x.sms.sender_id = ENV['UNIFONIC_SENDER_ID']
end
===========================================================================================================================================================


above changes are from the stash saves==== real worki are below 


==============================================================================================================================================================

below is in account controller account sign up code 

send_pin_via_sms(phone_number)

private
def send_pin_via_sms(phone)
  new_record = AccountBlock::SmsOtp.new(full_phone_number: phone)
  new_record.save
  # return (new_recor.valid_until - Time.current).to_i 
end

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
        message = "Your Pin Number is #{pin}"
        txt = BxBlockSms::SendSms.new("+#{full_phone_number}", message) =================================================================
        txt.call
      rescue Twilio::REST::RestError
        return true
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

  ===============================================================================================================================================

  module BxBlockSms
    class SendSms
      attr_reader :to, :text_content
  
      def initialize(to, text_content)
        @to = to
        @text_content = text_content
      end
  
      def call
        Provider.send_sms(to, text_content)============================================
      end
    end
  end

  
  ===========================================================

  app/services/bx_block_sms/provider.rb

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
  
          provider_klass.send_sms(to, text_content)==============================
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

  
  ===========================================================================================
  /template-app/app/services/bx_block_sms/providers/unifonic.rb

  +module BxBlockSms
+  module Providers
+    class Unifonic
+      BASE_URL = 'https://api.unifonic.com/rest'.freeze
+
+      class << self
+        def send_sms(to, text_content)
+          params = {
+            recipient: to,
+            body: text_content,
+            sender: Rails.configuration.x.sms.sender_id,
+            apiKey: Rails.configuration.x.sms.api_key
+          }
+
+          response = HTTParty.post("#{BASE_URL}/Messages/Send", body: params)
+          response.code == 200 ? true : false
+        end
+      end
+    end
+  end
+end