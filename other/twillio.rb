

in gemfile
    gem 'twilio-ruby'

in developement.rb and in production.rb
config.x.sms.provider = :twilio
config.x.sms.account_id = ENV['SMS_ACCOUNT_ID']
config.x.sms.auth_token = ENV['SMS_AUTH_TOKEN']
config.x.sms.from = ENV['SMS_FROM']