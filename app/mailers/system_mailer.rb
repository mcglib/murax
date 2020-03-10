class SystemMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL'],
          cc: ENV['ADMIN_EMAIL']

  def system_email(user, subject, message = nil)
     begin
        @user = User.find_by_user_key(user)
        @subject = subject
        @message = message if !message.nil?
        raise ArgumentError.new("User #{user} does not exist") if @user.nil?
        raise ArgumentError.new("A subject line is required in order to send an email.") if @subject.nil? || @subject.empty?
        mail(to: @user.email, 
             subject: @subject
        )
     rescue ArgumentError => e
        puts "Unable to send email (does the recipient have an account in eScholarship?): #{e}"
     end
  end

  def system_email_with_attachment(user, subject, message = nil, filepath)
     begin
        @user = User.find_by_user_key(user)
        @subject = subject
        @message = message if !message.nil?
        @filepath = filepath if !filepath.nil?
        raise ArgumentError.new("User #{user} does not exist") if @user.nil?
        raise ArgumentError.new("A subject line is required in order to send an email.") if @subject.nil? || @subject.empty?
        raise ArgumentError.new("A filename must be specified when using method system_email_with_attachment") if @filepath.nil?
        raise ArgumentError.new("Can't find the specified file #{@filepath}") if !File.exist?(@filepath) && !File.file?(@filepath)
        filename_part = @filepath.split('/')[-1]
        attachments["#{filename_part}"] = File.read(@filepath)
        mail(to: @user.email,
             subject: @subject
        )
     rescue ArgumentError => e
        puts "Unable to send email (does the recipient have an account in eScholarship?): #{e}"
     end
  end
end
