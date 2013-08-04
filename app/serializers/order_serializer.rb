class OrderSerializer < ActiveModel::Serializer
  attributes :id, :net_total, :decimal, :tax_total, :adjustment_total, :effective_date, :due_date, :user_id, :customer_id, :supplier_id, :state, :special_instructions, :notes
end
