ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address => CONFIG[:smtp_server],
    :port => 587,
    :domain => CONFIG[:mail_domain],
    :user_name => CONFIG[:mail_user_name],
    :password => CONFIG[:mail_password],
    :authentication => "plain",
    :enable_starttls_auto => true
}
ActionMailer::Base.default_url_options[:host] = "localhost:3000"
