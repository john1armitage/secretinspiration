Apartment.configure do |config|

  config.default_schema = "public"
  config.excluded_models = ["User", "Tenancy","Element"]
  config.persistent_schemas = ['public','hstorec']

end