module ApplicationHelper
  def select_item_type(item_types)
    if request.path.starts_with?('/concern/reports')
      item_type = item_types["Report"]
    elsif request.path.starts_with?('/concern/articles') 
      item_type = item_types["Article"]
    elsif request.path.starts_with?('/concern/theses')
      item_type = item_types["Thesis"]
    else 
      item_type = item_types["Thesis"]
    end
    return item_type
  end 
end
