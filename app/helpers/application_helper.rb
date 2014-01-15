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

  def markdown(text)
    #options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis]
    #Redcarpet.new(text, *options).to_html.html_safe
    #Redcarpet::Markdown.new(renderer, extensions = {})
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true).render(text).html_safe
  end

end
