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
	  markup << '<div class="panel panel-default">'
          markup << '<div class="panel-heading">'
          markup << '<h6>'
          markup << "#{return_lang_label(value)}"
	  markup << '</h6></div><div class="panel-body">'
          markup << "<li#{html_attributes(attributes)}>"
          markup << "#{attribute_value_to_html(value.to_s)}</li></div></div>"
        end
        # markup << %(</div>)
        markup << %(</ul></dd>)
        markup.html_safe
      end
     
      def lang_arr
	languages = [] 
	Qa::Authorities::Local.subauthority_for('languages').all.map do |element| 
	  languages << { id: element["id"],  label: element["label"] }
	end
	return languages
      end 

      def return_lang_label(value) 
        languages = lang_arr
        lang_label = value.last(3)
        languages.map do |lang|
	  id = lang[:id]
          id = id.last(3)
          term = id.first(2)
	  term_lang = lang[:label]
          if "@#{term}" == lang_label
            abs = term_lang
          else 
            next
          end
	  return abs
	end
      end

    end
  end
end
