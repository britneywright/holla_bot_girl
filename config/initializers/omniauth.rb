Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, "7ecccba5d7e44320be84efa653207412", "e4d53c9300504febbb772ec3550a8f99", scope: 'user-read-email playlist-modify-public user-library-read user-library-modify playlist-modify-private playlist-read-private'
end