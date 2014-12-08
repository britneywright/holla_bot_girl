require 'singleton'

class DB
  include Singleton

  def initialize
    @db = Sequel.connect(ENV['DATABASE_URL'])
  end

  def users
    @db[:users]
  end

  def new_user(nick,twitter,github)
    users.insert(:nick => nick, :twitter => twitter, :github => github)
  end

  def lookup_user(nick)
    users.filter(:nick => nick)
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.user = "holla_bot_girl"
    c.nick = "holla_bot_girl"
    c.channels = ["#theweekenders"]
  end

  helpers do
    def reply_random(m, list)
      m.reply list.sample
    end

    def spotify_artists(artists)
      artist = RSpotify::Artist.search(artists).first
      if artist == nil
        "Sorry, I don't know that artist."
      else
        "#{artist.name}-#{artist.top_tracks(:US).first.name}: #{artist.top_tracks(:US).first.uri}"
      end
    end

    def the_playlist
      RSpotify::Playlist.find('treehugrb','6RqttSsWmIm1Cpilw5obTI')
    end

    def add_to_playlist(song)
      the_playlist.add_tracks!(song, position: 0)
    end  


    def remove_from_playlist(song)
      the_playlist.remove_tracks!(song)
    end  

    def find_song(title)
      RSpotify::Track.search(title, limit: 1)
    end      
  end
  
  on :message, /^!help$/ do |m|
    m.user.send "Type !cute or cranky for pretty pictures."
    m.user.send "Tell us about yourself. Type !me nickname, twitter, github."
    m.user.send "Learn about others. Type !about nickname."
    m.user.send "Type !playlist to view our ##new2ruby playlist."
    m.user.send "Type !song and a song name (and artist if you know it) to return a link to share with others."
    m.user.send "Type !add and a song name (and artist if you know it) to add a song to the playlist."
    m.user.send "Type !artist and an artist or group name to return a link to their most popular track in US."
  end

  on :message, /^!improve/ do |m, title|
    m.reply "Submit a pull request or write an issue to improve me. https://github.com/britneywright/holla_bot_girl"
  end  

  on :message, /^(hello|hi|hey) holla_bot_girl/ do |m, nick|
    m.reply "Hello #{m.user.nick}"
  end

  on :message, /^(bye|goodbye) holla_bot_girl/ do |m, nick|
    m.reply "Goodbye #{m.user.nick}"
  end

  on :message, /^!me (.+), (.+), (.+)/ do |m, nick, twitter, github|
    DB.instance.new_user(nick, twitter, github)
    m.reply "You're alive!"
  end

  on :message, /^!(britney|master|owner)/ do |m|
    m.reply "britneywright made me"
  end

  on :message, /favorite song/ do |m|
    m.reply "My favorite song is Hollaback Girl http://www.youtube.com/watch?v=Kgjkth6BRRY"
  end

  on :message, /^!cute$/i do |m|
    reply_random m, [
    "http://justcuteanimals.com/wp-content/uploads/2014/11/Cat-in-the-Hat-funny-cute-animal-pictures.jpg",
    "http://images4.fanpop.com/image/photos/17800000/Cute-Panda-Cubs-Together-pandas-17838800-450-324.jpg",
    "http://www.funchap.com/wp-content/uploads/2014/05/help-dog-picture.jpg"
  ]
  end

  on :message, /cranky/i do |m|
    reply_random m, [
    "http://i272.photobucket.com/albums/jj172/lnglgs/cranky.jpg",
    "http://wac.450f.edgecastcdn.net/80450F/943thepoint.com/files/2012/06/cranky-baby-630x420.jpg",
    "http://res.mindbodygreen.com/img/ftr/MyCrankypants.jpg"
    ]
  end  

  on :message, /^!artist (.+)/ do |m, artists|
    m.reply spotify_artists(artists)
  end

  on :message, /^!about (.+)/ do |m, nick|
    user = DB.instance.lookup_user(nick)
    if user.get(:nick) != nil && user.get(:twitter) != nil && user.get(:github) != nil
      m.reply "You can find #{user.get(:nick)} at http://twitter.com/#{user.get(:twitter)} and http://github.com/#{user.get(:github)}"
    else
      m.reply "You're looking in the wrong place"
    end
  end

  on :message, /!song (.+)/ do |m, title|
    m.reply "#{find_song(title).first.name}: #{find_song(title).first.artists.map(&:name)} #{find_song(title).first.uri}"
  end

  on :message, /^!playlist/ do |m| 
    m.reply "#{the_playlist.name} (#{the_playlist.uri}): #{the_playlist.tracks.map(&:name).join(', ')}"
  end

  on :message, /^!add (.+)/ do |m, title|
    add_to_playlist(find_song(title))
    m.reply "I added that song to the playlist"
  end

  on :message, /^!remove (.+)/ do |m, title|
    remove_from_playlist(find_song(title))
    m.reply "I removed that song from the playlist"
  end     
end
bot.start