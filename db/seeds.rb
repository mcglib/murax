# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# Set up a default admin user
u = User.find_or_create_by(email: ENV['ADMIN_EMAIL'] || 'admin@example.com')
u.display_name = ENV['ADMIN_NAME'] || "Default Admin"
u.password = ENV['ADMIN_PASSWORD'] || 'password'
u.save

#  Create the user roles
roles = ['admin', 'archivist', 'donor', 'researcher', 'patron', 'admin_policy_object_editor']
roles.each do |role|
  Role.create(name: "#{role}")
end

# Add u  to all the admin role
admin_role = Role.find_or_create_by(name: 'admin')
admin_role.users << u
admin_role.save

