class StaticPagesController < ApplicationController

  def index
    @artist = RSpotify::Artist.search("Ed Sheeran").first.top_tracks(:US).first.name
  end
end