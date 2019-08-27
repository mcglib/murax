module ApplicationHelper
  # This helper provides the item type. currently being used in /views/records/edit_fields/_rtype.html.erb. 
  def item_type_helper
    item_url = request.original_fullpath
    item_split = item_url.split('/')
    item_type = item_split[2]
    item_type = item_type.capitalize.singularize
    return item_type
  end

  def item_rights_helper
    return "Book"
  end
end
