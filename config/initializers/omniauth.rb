Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, ENV['KEY1'], ENV['KEY2'], scope: 'user-read-email playlist-modify-public user-library-read user-library-modify playlist-modify-private playlist-read-private'
end