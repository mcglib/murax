# [hyc-override] Overriding hydra editor custom input to allow for multivalue HTML5 dates
# https://github.com/samvera/hydra-editor/blob/master/app/inputs/multi_value_input.rb
include LanguagesService
class MultiValueAbstractInput < MultiValueInput
  def input_type
    'multi_value'.freeze
  end
  
  def input(wrapper_options)
    @rendered_first_element = false
    input_html_classes.unshift('string')
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"

    authority = Qa::Authorities::Local.subauthority_for('languages')
    #authority.all.each do |lang| 
    #end
    outer_wrapper do
      buffer_each(collection) do |valuex, index|
        inner_wrapper do
          clean_value = strip_lang_prefix(valuex)
          curr_lang = get_lang_prefix(valuex)
          out = build_field(clean_value, index, authority)
          "#{out}#{build_select_options(authority, curr_lang, attribute_name, index)}"
        end
      end
    end
  end

  def input_html_classes
    super.push('select2 lang-selector')
  end

  protected

  def strip_lang_prefix(value)
    clean_value = value.dup
    # Remove quotes
    new_text = clean_value.gsub!(/^\"|\"?$/, '')
    # Remove the lang prefix
    t = new_text.gsub!(/\"@\w{2,3}$/, "")
    # Return clean values
    clean_value = t
  end

  def get_lang_prefix(value)
    clean_value = value.dup
    lang_prefix = "eng"
    # Remove quotes
    new_text = clean_value.gsub!(/^\"|\"?$/, '')
    lang_prefix = new_text.last(3)
    clean_value.gsub(/(\"@\w{2,3})$/) { lang_prefix = $1}
    byebug
    lang_uri = get_language_uri(lang_prefix) if !lang_prefix.blank?
    lang_label = LanguagesService.label(lang_uri)  if !lang_prefix.blank?
    # Remove the lang prefix
    #t = value.gsub!(/\"@\w{2,3}$/, "")
    # Return clean values
    #clean_value = t

    lang_prefix
  end
  
  # Use language code to get iso639-2 uri from service
  def get_language_uri(language_codes)
    language_codes.map{|e| LanguagesService.label("http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}") ?
            "http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}" : e}
  end

  def buffer_each(collection)
    collection.each_with_object('').with_index do |(value, buffer), index|
      buffer << yield(value, index)
    end
  end

  def outer_wrapper
     "    <ul class='listing draggable-order dd-list' data-object-name='#{object_name}'>
                 #{yield}
           </ul>
     "
  end
 
  def inner_wrapper
    <<-HTML
          <li class="field-wrapper">
            #{yield}
          </li>
    HTML
  end

  private

  # Although the 'index' parameter is not used in this implementation it is useful in an
  # an overridden version of this method, especially when the field is a complex object and
  # the override defines nested fields.
  def build_field_options(value, index)
    options = input_html_options.dup


    #options[:value] = value if options[:value].nil?
    if !value.blank?
      options[:value] = value
    elsif value.blank? and !options[:value].blank?
      options[:value] = options[:value]
    else
      options[:value] = value
    end


    if @rendered_first_element
      options[:id] = nil
      options[:required] = nil
    else
      options[:id] ||= input_dom_id
    end
    options[:class] ||= []
    options[:class] += ["#{input_dom_id} form-control multi-text-field"]
    options[:'aria-labelledby'] = label_id
    @rendered_first_element = true

    options
  end

  def build_select_options(authority_lang,curr_lang, attribute_name,index)
     buffer = "<select name='language_select' id='lang_#{attribute_name}_#{index}' class='select2 lang-selector'>"
      authority_lang.all.each do |lang| 
        buffer << "<option value='#{lang[:id]}'>#{lang[:label]}</option>"
      end
      buffer << "</select>"

      buffer
  end
  def build_field(value, index, authority_lang)
    options = build_field_options(value, index)
    if options.delete(:type) == 'textarea'.freeze
      @builder.text_area(attribute_name, options)
    elsif options[:class].include? 'integer-input' #[hyc-override] multivalue integers
      @builder.number_field(attribute_name, options)
    elsif options[:class].include? 'date-input' #[hyc-override] multivalue dates
      @builder.date_field(attribute_name, options)
    else
      @builder.text_field(attribute_name, options)
    end
  end

  def build_select_field(lang, index)
  end

  def label_id
    input_dom_id + '_label'
  end

  def input_dom_id
    input_html_options[:id] || "#{object_name}_#{attribute_name}"
  end

  def collection
    @collection ||= begin
      val = object.send(attribute_name)
      col = val.respond_to?(:to_ary) ? val.to_ary : val
      col.reject { |valuex| valuex.to_s.strip.blank? } + ['']
    end
  end

  def multiple?; true; end
end
