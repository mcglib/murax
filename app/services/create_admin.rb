class CreateAdmin
  def self.call
    user = User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
        user.password = Rails.application.secrets.admin_password
        user.password_confirmation = Rails.application.secrets.admin_password
        user.username = Rails.application.secrets.admin_username
        user.email = Rails.application.secrets.admin_email
        user.confirm
        ## set the user roles
        user.role = Role.find_by_name('admin')
    end
  end
end
