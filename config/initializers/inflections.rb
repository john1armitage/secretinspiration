# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
   #inflect.plural /^(ox)$/i, '\1en'
   #inflect.singular /^(ox)en/i, '\1'
  # inflect.irregular 'Caribbean', 'Caribbean'
  # inflect.irregular 'Urban Country', 'Urban Country'
  # inflect.irregular 'MiPac', 'MiPac'
  # inflect.irregular 'Sweet Trolley', 'Sweet Trolley'
  # inflect.irregular 'headwear', 'headwear'
  # inflect.irregular 'Food', 'Food'
  # inflect.irregular 'Scented', 'Scented'
  # #inflect.irregular 'Art', 'Art'      # messes up cart schema!!
  # inflect.irregular 'Fibre', 'Fibre'
  # inflect.irregular 'catalogue', 'catalogue'
  inflect.uncountable %w(clearance semi-precious jewellery sundry art stuff collection catalogue fibre scented food headwear trolley MiPac 'Urban Country' caribbean oggi soapstone)
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
