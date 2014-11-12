require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HollaBotGirl
  class Application < Rails::Application
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'environment_variables.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
    RSpotify::authenticate(ENV['KEY1'], ENV['KEY2'])
  end
end
Thread.new do
    require File.expand_path('../../lib/cinch', __FILE__)
end