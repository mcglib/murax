module Hyrax
  module Renderers
    class RtypeAttributeRenderer < AttributeRenderer
        #Draw the table row for the attribute
        def render
          markup = ''

          return markup if values.blank? && !options[:include_empty]
          markup << %(<tr><th>Type</th>\n<td><ul class='tabular'>)
          attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
          Array(values).each do |value|
            markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
          end
          markup << %(</ul></td></tr>)
          markup.html_safe
        end
        # Draw the dl row for the attribute
        def render_dl_row
          markup = ''
          return markup if values.blank? && !options[:include_empty]
          markup << %(<dt>Type</dt>\n<dd><ul class='tabular'>)
          attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
          Array(values).each do |value|
            markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
          end
          markup << %(</ul></dd>)
          markup.html_safe
        end
       

        # make it faceted.
        def li_value(value)
          link_to(ERB::Util.h(value), search_path(value))
        end

        def search_path(value)
          Rails.application.routes.url_helpers.search_catalog_path(:"f[#{search_field}][]" => value, locale: I18n.locale)
        end

        def search_field
          ERB::Util.h(Solrizer.solr_name(options.fetch(:search_field, field), :facetable, type: :string))
        end
    end
  end
end
