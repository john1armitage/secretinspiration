module Permissions
  def self.permission_for(user)

    if user.id.blank?
        role = 'guest'
      else
        role = user.role ? user.role.name : 'user'
      end
    case role
      when 'admin'
        AdminPermission.new(user)
      when 'manager'
        ManagerPermission.new(user)
      when 'operator'
        OperatorPermission.new(user)
      when 'user'
        UserPermission.new(user)
      else
        GuestPermission.new      # not logged in
    end

  end
end