class Tenancy < ActiveRecord::Base

  after_create :create_schema

  def create_schema
    ActiveRecord::Base.connection.execute("carts schema #{domain}")
    scope_schema do
      load Rails.root.join("db/schema.rb")
      ActiveRecord::Base.connection.execute("drop table #{self.class.table_name}")
    end
  end

  def scope_schema(*paths)
    original_search_path = ActiveRecord::Base.connection.schema_search_path
    ActiveRecord::Base.connection.schema_search_path = [domain, *paths].join(",")
    yield
  ensure
    ActiveRecord::Base.connection.schema_search_path = original_search_path
  end

  def component_tokens
    fields = []
    Element.where( :kind => 'component').order(:rank, :name).each do |field|
      fields << field.name if eval("#{field.present?} && #{field.name} == '1'")
    end
    fields
  end

  def component_tokens=(fields)
    blank_fields
    fields.each do |field|
      eval("self.#{field} = '1'")  unless field.blank?
    end
  end

  Element.where( :kind => 'component').each do |domain|
    store_accessor :properties, domain.name
  end

  def blank_fields
    Element.where( :kind => 'component').each do |field|
      eval("self.#{field.name} = ''")
    end
  end



end
