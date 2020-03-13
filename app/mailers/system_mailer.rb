class SystemMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL']

  invalid_user_message = "User does not exist (does the recipient have an account in eScholarship?"
  missing_subject_message = "A subject line is required in order to send an email."
  missing_message = "You must provide text for the body of the email"

  # @param user [String] email address of user to whom the message will be sent. The user must have a valid account in Samvera.
  # @param subject [String] text to use as subject line of email
  # @param body_text [String] text to use a body of email message
  def system_email(user, subject, body_text)
     begin
        @user = User.find_by_user_key(user)
        @subject = subject
        @message = body_text if !body_text.nil?
        raise ArgumentError.new("#{invalid_user_message} #{user}") if @user.nil?
        raise ArgumentError.new("#{missing_subject_message}") if @subject.nil? || @subject.empty?
        raise ArgumentError.new("#{missing_message}") if @message.nil?
        mail(to: @user.email, 
             subject: @subject
        )
     rescue ArgumentError => e
        puts "Unable to send email: #{e}"
     end
  end

  # @param user [String] email address of user to whom the message will be sent. The user must have a valid account in Samvera.
  # @param subject [String] text to use as subject line of email
  # @param body_text [String] text to use a body of email message
  # @param filepaths [String] full path and filename of file(s) to be sent as attachment(s). Use separator (described below) to submit more than one filepath.
  # @param separator [String] Optional string used to split the filepaths argument above. The default is the space character.
  def system_email_with_attachment(user, subject, body_text, filepaths, separator = ' ')
     begin
        @user = User.find_by_user_key(user)
        @subject = subject
        @message = body_text if !body_text.nil?
        @filepaths = filepaths if !filepaths.nil?
        @separator = separator
        raise ArgumentError.new("#{invalid_user_message} #{user}") if @user.nil?
        raise ArgumentError.new("#{missing_subject_message}") if @subject.nil? || @subject.empty?
        raise ArgumentError.new("#{missing_message}") if @message.nil?
        raise ArgumentError.new("At least one filename must be specified when using method system_email_with_attachment") if @filepaths.nil?
        @filepaths = @filepaths.split(@separator) if @filepaths.include? @separator
        if @filepaths.respond_to? :each
          @filepaths.each do |fp|
            add_attachment(fp)
          end
        else
          add_attachment(@filepaths)
        end
        mail(to: @user.email,
             subject: @subject
        )
     rescue ArgumentError => e
        puts "Unable to send email: #{e}"
     end
  end

  def add_attachment(this_filepath)
     begin
       raise ArgumentError.new("Can't find the specified file #{this_filepath}") if !File.exist?(this_filepath) && !File.file?(this_filepath)
       filename_part = this_filepath.split('/')[-1]
       mail.attachments["#{filename_part}"] = File.read(this_filepath)
     rescue ArgumentError => e
        puts "#{e}"
     end
  end
end
