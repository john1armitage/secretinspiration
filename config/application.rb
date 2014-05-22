require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'net/http'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, :assets, Rails.env)
CONFIG = YAML.load(File.read(File.expand_path('../commerce.yml', __FILE__)))
CONFIG.merge! CONFIG.fetch(Rails.env, {})
CONFIG.symbolize_keys!

module Commerce
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    #config.middleware.use 'Apartment::Elevators::Generic', Proc.new { |request| get_domain(request.host.reverse) }

    config.active_record.schema_format = :sql
    config.beginning_of_week = :sunday
    #config.middleware.use 'Apartment::Elevators::Generic', Proc.new { |request| request.host.reverse }
    #config.middleware.use 'Apartment::Elevators::Subdomain'
    #config.middleware.use 'Apartment::Elevators::Domain'
    #config.middleware.use 'Apartment::Elevators::Hosthash', {'localhost' => 'secret'}
    #config.middleware.use 'Apartment::Elevators::HostHash', {'127.0.0.1' => 'shack'}
    #config.middleware.use 'Apartment::Elevators::HostHash', {'secretinspiration.co.uk' => 'secret'}
    #config.middleware.use 'Apartment::Elevators::HostHash', {'peppershack.co.uk' => 'shack'}
    #config.middleware.use 'Apartment::Elevators::HostHash', {'gigiri.co.uk' => 'gigiri'}

    def get_domain( hostname )
      case hostname
        when 'localhost', 'secretinspiration.co.uk'
          'secret'
        when '127.0.0.1', 'peppershack.co.uk'
          'shack'
        when 'gigiri'
          'gigiri'            #gigiri
      end
    end

  end

end
