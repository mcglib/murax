module Hyrax
  # Provide select options for the language field
  class LanguageService < QaSelectService
    def initialize(_authority_name = nil)
      super('languages')
    end
  end
end
