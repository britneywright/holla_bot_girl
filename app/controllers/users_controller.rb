class UsersController < ApplicationController
  def spotify
    @spotify_user = RSpotify::User.new(auth_hash)
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end