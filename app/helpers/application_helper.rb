module ApplicationHelper
  def select_item_type(item_types)
    if request.path.starts_with?('/concern/reports')
      item_type = item_types["Report"]
    elsif request.path.starts_with?('/concern/articles') 
      item_type = item_types["Article"]
    elsif request.path.starts_with?('/concern/theses')
      item_type = item_types["Thesis"]
    elsif request.path.starts_with?('/concern/books')
      item_type = item_types["Book"]
    elsif request.path.starts_with?('/concern/papers')
      item_type = item_types["Paper"]
    elsif request.path.starts_with?('/concern/presentations')
      item_type = item_types["Presentation"]
    else 
      item_type = item_types["Thesis"]
    end
    return item_type
  end

  def select_type
    item_url = request.original_fullpath
    item_split = item_url.split('/')
    item_type = item_split[2]
    item_type = item_type.capitalize.singularize
    return item_type
  end 
end
