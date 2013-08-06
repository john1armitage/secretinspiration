class Category < ActiveRecord::Base

  has_ancestry :cache_depth => true, :orphan_strategy => :adopt

  has_many :categories
  has_many :items, :as => :grouping
  has_many :items

  belongs_to :root, :class_name => 'Category'

  validates :name, uniqueness: true, presence: true

  after_validation :hack_root

  before_save :set_ancestors

  default_scope :order => 'rank, name ASC'
#  default_scope :order, -> { order('rank, name ASC') }

  def nice_name
  name.gsub(/_/," ").titleize
  end

  def hack_root
    if ancestry == '0'
      self.ancestry = nil
    end
  end

  def set_ancestors
    self.root_id = ( ancestry.blank? ?  id : ancestry.gsub(/\/.+/, '') )
    self.category_id = ancestry.gsub(/.+\//, '') if ancestry
  end

end
