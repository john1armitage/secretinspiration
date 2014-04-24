class Element < ActiveRecord::Base

  Element.where( :kind => 'domain').each do |domain|
    store_accessor :properties, domain.name
  end


end
