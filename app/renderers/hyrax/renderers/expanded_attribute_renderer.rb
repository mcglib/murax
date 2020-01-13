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
          markup << "<h5>#{return_lang_label(value)}</h5>"
          markup << '</h5></div><div class="panel-body">'
          markup << "<li#{html_attributes(attributes)}>"
          markup << "#{attribute_value_to_html(value.to_s)}</li></div></div>"
        end
        # markup << %(</div>)
        markup << %(</ul></dd>)
        markup.html_safe
      end
      def attribute_value_to_html(value)
        if label == "Abstract"
          result = value.gsub(/"@\w{2,3}$/, "")
          value = result.delete_prefix("\"")
        end
        if microdata_value_attributes(field).present?
          "<span#{html_attributes(microdata_value_attributes(field))}>#{li_value(value)}</span>"
        else
          li_value(value)
        end
      end

      private
        def lang_arr
          languages = [] 
          Qa::Authorities::Local.subauthority_for('languages').all.map do |element| 
            languages << { id: element["id"],  label: element["label"] }
          end
          languages
        end 

        def return_lang_label(value)
          label = nil 
          languages = lang_arr
          lang_label = value.last(3)
          # remove the @ if any in the lang_label
          lang_label.gsub!(/@/,"")

          # We add an execption for English and French 
          # that were added with 2 char code instead of 3 char
          # eg "en" instead of "eng"
          # so we map "en" -> "eng" and
          # we map "fr" -> "fre".
          lang_label = "eng" if lang_label.downcase == "en"
          lang_label = "fre" if lang_label.downcase == "fr"
          languages.map do |lang|
            lang_code = lang[:id].match(/(\w{2,3})$/) {|m| m.captures}
            #id = lang[:id].gsub(/"(\w{2,3})$/","")
            if lang_code.first == lang_label.downcase
              label = lang[:label]
              break
            end
          end
          label
        end
    end
  end
end
