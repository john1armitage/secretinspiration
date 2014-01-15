class Topic < ActiveRecord::Base

  has_many :pages

  validates_presence_of :name, :message => 'is required'
  validates_numericality_of :rank, :allow_nil => true

end
