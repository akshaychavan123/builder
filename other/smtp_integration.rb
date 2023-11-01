config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  user_name:            'surendra01046@gmail.com',
  password:             'mjyeevdmkhydrmrq',
  authentication:       'plain',
  enable_starttls_auto: true,
  openssl_verify_mode: "none"
}

only these above changes are need to be have in developement file and nowhere else 
other extra configuration can have problems on developement url although working on localhost
