# Load the rails application
require File.expand_path('../application', __FILE__)
ActionMailer::Base.delivery_method = :sendmail
# Initialize the rails application
SpecrightDev::Application.initialize!
