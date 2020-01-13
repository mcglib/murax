module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  def language_links(options)
    begin
      to_sentence(options[:value].map { |lang| link_to LanguagesService.label(lang), main_app.search_catalog_path(f: { language_sim: [lang] })})
    rescue KeyError
      nil
    end
  end

  def language_links_facets(options)
    begin
      link_to LanguagesService.label(options), main_app.search_catalog_path(f: { language_sim: [options] })
    rescue KeyError
      options
    end
  end

  # This method is used in views/hyrax/base/_attribute_rows.html.erb and provides link for thesis only worktypes. 
  def thesis_identifier_field(presenter)
    if presenter.human_readable_type.downcase == 'thesis'
      presenter.attribute_to_html(:identifier, render_as: :external_link, search_field: 'identifier_tesim', html_dl: true)
    else
      presenter.attribute_to_html(:identifier, render_as: :linked, search_field: 'identifier_tesim', html_dl: true)
    end
  end

# This methods returns the two digit language code prepended with @ sign from language authority id. 
  def language_abstract_code(str)
    append_symbol = '"@'
    get_language_code = str.last(3)
    language_code = get_language_code.first(2)
    abstract_append_code = append_symbol + language_code
    return  abstract_append_code
  end

end
