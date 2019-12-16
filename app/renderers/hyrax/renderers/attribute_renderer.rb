require "rails_autolink/helpers"

module Hyrax
  module Renderers
    class AttributeRenderer
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TranslationHelper
      include ActionView::Helpers::TextHelper
      include ConfiguredMicrodata

      attr_reader :field, :values, :options

      # @param [Symbol] field
      # @param [Array] values
      # @param [Hash] options
      def initialize(field, values, options = {})
        @field = field
        @values = values
        @options = options
      end

      # Draw the table row for the attribute
      def render
        markup = ''

        return markup if values.blank? && !options[:include_empty]

        markup << %(<tr class="custom-field-row"><th class="custom-tb custom-tb-#{label}">#{label}</th>\n<td class="custom-td-#{field} custom-field-description"><ul class='tabular custom-tabular-ul'>)
        attributes = microdata_object_attributes(field).merge(class: "custom-attribute-#{field} attribute attribute-#{field}")
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
        markup << %(<dt class="custom-dt custom-dt-#{label}">#{label}</dt>\n<dd class="custom-dd-#{field} custom-field-description"><ul class='tabular custom-tabular-ul'>)
        attributes = microdata_object_attributes(field).merge(class: "custom-attribute-#{field} attribute attribute-#{field}")
        Array(values).each do |value|
          markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
        end
        markup << %(</ul></dd>)
        markup.html_safe
      end

      # @return The human-readable label for this field.
      # @note This is a central location for determining the label of a field
      #   name. Can be overridden if more complicated logic is needed.
      def label
        translate(
          :"blacklight.search.fields.#{work_type_label_key}.show.#{field}",
          default: [:"blacklight.search.fields.show.#{field}",
                    :"blacklight.search.fields.#{field}",
                    options.fetch(:label, field.to_s.humanize)]
        )
      end

      private

        def attribute_value_to_html(value)
          if microdata_value_attributes(field).present?
            "<span#{html_attributes(microdata_value_attributes(field))}>#{li_value(value)}</span>"
          else
            li_value(value)
          end
        end

        def html_attributes(attributes)
          buffer = ""
          attributes.each do |k, v|
            buffer << " #{k}"
            buffer << %(="#{v}") if v.present?
          end
          buffer
        end

        def li_value(value)
          auto_link(ERB::Util.h(value))
        end

        def work_type_label_key
          options[:work_type] ? options[:work_type].underscore : nil
        end
    end
  end
end
