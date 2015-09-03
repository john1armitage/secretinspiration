# #Money.silence_core_extensions_deprecations = true
# # raw config
#
# currencies = []
#
# currencies[0] = {
#     :priority        => 1,
#     :iso_code        => "GBP",
#     :iso_numeric     => "826",
#     :name            => "Pound Sterling",
#     :symbol          => "£",
#     :symbol_first        => true,
#     :subunit         => "Penny",
#     :subunit_to_unit => 100,
#     :separator       => ".",
#     :delimiter       => ","
# }
# currencies[1] = {
#     :priority        => 2,
#     :iso_code        => "KES",
#     :iso_numeric     => "404",
#     :name            => "Kenya Shilling",
#     :symbol          => "$",
#     :symbol_first        => true,
#     #:subunit         => "Shilling",
#     #:subunit_to_unit => 1,
#     :separator       => ".",
#     :delimiter       => ","
# }
# currencies[2] = {
#     :priority        => 3,
#     :iso_code        => "ZAR",
#     :iso_numeric     => "710",
#     :name            => "South Africa Rand",
#     :symbol          => "R",
#     :symbol_first        => true,
#     #:subunit         => "Shilling",
#     #:subunit_to_unit => 1,
#     :separator       => ".",
#     :delimiter       => ","
# }
# currencies[3] = {
#     :priority            => 4,
#     :iso_code            => "EUR",
#     :name                => "Euro",
#     :symbol              => "€",
#     :symbol_first        => true,
#     :subunit             => "Cent",
#     :subunit_to_unit     => 100,
#     :thousands_separator => ".",
#     :decimal_mark        => ","
# }
# currencies[4] = {
#     :priority        => 4,
#     :iso_code        => "USD",
#     :iso_numeric     => "840",
#     :name            => "United States Dollar",
#     :symbol          => "$",
#     :symbol_first        => true,
#     :subunit         => "Cent",
#     :subunit_to_unit => 100,
#     :separator       => ".",
#     :delimiter       => ","
# }
#
# currencies.each do |currency|
#   Money::Currency.register(currency)
# end
#
# Money.default_currency = Money::Currency.new("GBP")
# #MultiJson.engine = :json_gem
#
# #Money.default_bank = Money::Bank::HistoricalBank.new
#
# # MoneyRails.configure do |config|
# #
# #   config.include_validations = true
# #
# end

