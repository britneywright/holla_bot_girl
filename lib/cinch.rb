require 'singleton'

class DB
  include Singleton

  def initialize
    @db = Sequel.connect(:adapter=>'postgres', :host=>'localhost', :database=>'holla_bot_girl', :user=>'britneywright')
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
    m.reply "Type !cute or cranky for pretty pictures."
    m.reply "Tell us about yourself. Type !me nickname, twitter, github."
    m.reply "Learn about others. Type !stalk nickname."
    m.reply "More help to come!"
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

  on :message, /^hello holla_bot_girl/ do |m, nick|
    m.reply "Hello #{m.user.nick}"
  end

  on :message, /^bye holla_bot_girl/ do |m, nick|
    m.reply "Goodbye #{m.user.nick}"
  end

  on :message, /^!me (.+), (.+), (.+)/ do |m, nick, twitter, github|
    DB.instance.new_user(nick, twitter, github)
    m.reply "You're alive!"
  end

  on :message, /^!stalk (.+)/ do |m, nick|
    user = DB.instance.lookup_user(nick)
    if user.get(:nick) != nil && user.get(:twitter) != nil && user.get(:github) != nil
      m.reply "You can find #{user.get(:nick)} at http://twitter.com/#{user.get(:twitter)} and http://github.com/#{user.get(:github)}"
    else
      m.reply "You're stalking in the wrong place"
    end
  end

  on :message, /!my twitter/ do |m| 
    user = DB.instance.lookup_user(m.user.nick)
    m.reply "Your twitter handle is #{user.get(:twitter)}"
  end

  on :message, /!song (.+)/ do |m, title|
    m.reply "#{find_song(title).first.name}: #{find_song(title).first.artists.map(&:name)} #{find_song(title).first.uri}"
  end

  on :message, /^!playlist/ do |m| 
    m.reply "#{the_playlist.name} (#{the_playlist.uri}): #{the_playlist.tracks.map(&:name)}"
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