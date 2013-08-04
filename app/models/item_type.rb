class ItemType < ActiveRecord::Base

  has_many :items

  belongs_to  :account

  validates_presence_of :account

  attr_reader :field_tokens

  def required_field_tokens
    fields = []
    ItemField.order(:rank, :name).each do |field|
      fields << field.name if eval("#{field.present?} && ( #{field.name} == 'require')")
    end
    fields
  end

  def required_field_tokens=(fields)
    fields.each do |field|
      eval("self.#{field} = 'require'") unless field.blank?
    end
  end

  def optional_field_tokens
    fields = []
    ItemField.order(:rank, :name).each do |field|
      fields << field.name if eval("#{field.present?} && #{field.name} == 'include'")
    end
    fields
  end

  def optional_field_tokens=(fields)
    fields.each do |field|
      eval("self.#{field} = 'include'")  unless field.blank?
    end
   end

  def collection_tokens
    fields = []
    ItemField.order(:rank, :name).each do |field|
      fields << field.name if eval("#{field.present?} && #{field.name} == 'collection'")
    end
    fields
  end

  def collection_tokens=(fields)
    fields.each do |field|
      eval("self.#{field} = 'collection'")  unless field.blank?
    end
  end

  def options_tokens
    fields = []
    ItemField.order(:rank, :name).each do |field|
      fields << field.name if eval("#{field.present?} && #{field.name} == 'options'")
    end
    p fields
    fields
  end

  def options_tokens=(fields)
    fields.each do |field|
      eval("self.#{field} = 'options'") unless field.blank?
    end
  end

  def blank_fields
    ItemField.all.each do |field|
      eval("self.#{field.name} = ''")
    end
  end

  Element.where( :kind => 'domain').each do |domain|
    store_accessor :properties, domain.name
  end

  ItemField.order(:rank, :name).each do |field|
    store_accessor :properties, field.name
  end

end
