module Hyrax
  # Provide select options for the rtype field
  class ResourceTypeAuthorities < QaSelectService
    def initialize
      super('resource_types')
    end
  end
end
