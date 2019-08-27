class Ability
  include Hydra::Ability
 
  include Hyrax::Ability
 #self.ability_logic += [:everyone_can_create_curation_concerns]
  self.ability_logic += [:custom_permissions]
  self.ability_logic += [:casual_workers]
  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    if current_user.admin?
       can [:destroy], ActiveFedora::Base
    end

    if current_user.repository_managers?
       can [:destroy], ActiveFedora::Base
    end 

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end


    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end

    if current_user.repository_managers?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    end

  end

  # Persmissions for casual workers
  def casual_workers
    if user_groups.include? 'casual_workers'
      can [:create, :show, :edit,  :index, :update], ActiveFedora::Base
    end

    if user_groups.include? 'casual_workers'
      can [:create, :show, :index, :edit,  :update], Role
    end

    if current_user.casual_workers?
      can [:create, :show, :index, :edit, :update], Role
    end

    if user_groups.include? 'casual_workers'
      cannot [:destroy], ActiveFedora::Base
    end
  end

end









