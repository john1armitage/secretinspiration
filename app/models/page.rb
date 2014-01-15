class Page < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user

  validates_presence_of :title, :message => 'is required'
  validates_presence_of :code, :message => 'is required'
  validates_presence_of :body, :message => 'is required'

end
