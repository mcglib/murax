module ApplicationHelper
  # This helper provides the item type. currently being used in /views/records/edit_fields/_rtype.html.erb.
  def item_type_helper
    item_url = request.original_fullpath
    item_split = item_url.split('/')
    item_type = item_split[2]
    item_type = item_type.capitalize.singularize
    return item_type
  end

  # This helper provides the default value for the rights statement. currently being used in /views/records/edit_fields/_rights.html.erb.
  def item_rights_helper(property_obj)
    default_val = ""
    if property_obj.count === 1 and property_obj.first.empty?
      default_val = t('hyrax.default_rights_statement')
    end

    default_val
  end

  # This helper sets the background color for header and footer differently for users that are not logged in. 
  def default_header_background_color
    if !user_signed_in? 
      color = '#004080'
    end
    return color
  end

end
