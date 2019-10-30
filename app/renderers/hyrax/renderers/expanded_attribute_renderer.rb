module Hyrax
  module Renderers
    class ExpandedAttributeRenderer < AttributeRenderer
            # Draw the dl row for the attribute
      def render_dl_row
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        markup << %(<dt class="custom-dt custom-dt-#{label}">#{label}</dt>\n<dd class="custom-dd-#{field} custom-field-description"><ul class='tabular custom-tabular-ul'>)
        attributes = microdata_object_attributes(field).merge(class: "only-so-big custom-attribute-#{field} attribute attribute-#{field}")
       	# markup << %(<div class="only-so-big">)
        Array(values).each do |value|
          markup << "<li#{html_attributes(attributes)}>"
          markup << "#{attribute_value_to_html(value.to_s)}</li><br>"
        end
        # markup << %(</div>)
        markup << %(</ul></dd>)
        markup.html_safe
      end
    end
  end
end
