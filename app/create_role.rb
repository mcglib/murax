class CreateRole
  def self.call(role_params, date_created = nil, previous_id = nil)
    begin
      @form = RoleForm.new(Role.new)
      if !@form.validate(role_params)
        raise "Form failed to validate with errors #{@form.errors.join " "}"
      end

      @form.save

      role = @form.model
      role.update_attribute :created_at, date_created if !date_created.nil?
      role
    rescue => e
      puts "Error occured creating the role for #{role_params[:name]}: Error: #{e} -  #{@form.errors}"
      false
    end
  end
end
