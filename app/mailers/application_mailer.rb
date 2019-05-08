class ApplicationMailer < ActionMailer::Base
  default from: 'dev.library@mcgill.ca'
  layout 'mailer'
end
