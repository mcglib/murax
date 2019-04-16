module Hyrax
  module Renderers
    class UpcaseAttributeRenderer < AttributeRenderer
      private
        def label
          translate(
            :"blacklight.search.fields.#{work_type_label_key}.show.#{field}",
            default: [:"blacklight.search.fields.show.#{field}",
                    :"blacklight.search.fields.#{field}",
                    options.fetch(:label, field.to_s.humanize.upcase)]
          )
        end

    end
  end
end
