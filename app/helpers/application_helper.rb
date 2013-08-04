module ApplicationHelper
  include PgArrayParser

  def lookup_roles
    Element.where( :kind => 'role').order(:rank)
  end

  def get_categories_for_item_type
    @categories = Category.after_depth(1).select(:id, :name, :parent_name).load
  end

  def make_title(input)
    input.gsub(/_/," ").gsub(/[^0-9a-z ]/i, '').titleize
  end

  def parse_pg( pg_array )
    pg_array.parse_pg_array
  end

end
