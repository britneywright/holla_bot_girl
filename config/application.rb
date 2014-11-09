require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HollaBotGirl
  class Application < Rails::Application
    RSpotify::authenticate("7ecccba5d7e44320be84efa653207412", "e4d53c9300504febbb772ec3550a8f99")
  end
end
Thread.new do
    require File.expand_path('../../lib/cinch', __FILE__)
end