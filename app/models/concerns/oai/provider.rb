require 'oai'

module OAI::Provider
  Base.class_eval do
     Base.register_format(OAI::Provider::Metadata::Etdms.instance)
  end
end
