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
      default_val = ENV['DEFAULT_RIGHTS_STATEMENT'].tr('"', '')
    end

    default_val
  end

end
