module Hyrax
  module Renderers
    class ShowMoreAttributeRenderer < AttributeRenderer
            # Draw the dl row for the attribute
      def render_dl_row
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        markup << %(<div id="module">)
        markup << %(<dt class="custom-dt custom-dt-#{label}">#{label}</dt>\n<dd class="custom-dd-#{field} custom-field-description"><ul class='tabular custom-tabular-ul'>)
        attributes = microdata_object_attributes(field).merge(class: "collapse custom-attribute-#{field} attribute attribute-#{field}")
        Array(values).each do |value|
          markup << "<li#{html_attributes(attributes)}"
          markup << 'id="collapseAbstract" aria-expanded="false" >'
          markup << "#{attribute_value_to_html(value.to_s)}</li>"
          markup << '<a role="button" class="collapsed" data-toggle="collapse" href="#collapseAbstract" aria-expanded="false" aria-controls="collapseAbstract"></a>'
        end
        markup << %(</div>)
        markup << %(</ul></dd>)
        markup.html_safe
      end
    end
  end
end
