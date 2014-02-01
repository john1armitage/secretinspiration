ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address => "smtp.1und1.de",
    :port => 587,
    :domain => "familya.co.uk",
    :user_name => CONFIG[:mail_user_name],
    :password => CONFIG[:mail_password],
    :authentication => "plain",
    :enable_starttls_auto => true
}
ActionMailer::Base.default_url_options[:host] = "localhost:3000"
