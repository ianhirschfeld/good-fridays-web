require 'dotenv'
require 'json'
require 'sinatra'
require 'soundcloud'

Dotenv.load

# Routes

get '/tracks.json' do
  load_client
  tracks = get_official_tracks
  tracks.map do |track|
    if track.stream_url
      {
        id: track.id,
        title: track.title,
        duration: track.duration,
        artwork_url: track_artwork_url(track),
        stream_url: "#{track.stream_url}?client_id=#{ENV['SOUNDCLOUD_CLIENT_ID']}",
        source: 'SoundCloud',
        uploader: track.user.username,
      }
    end
  end.compact.to_json
end

get '/tracks_v2.json' do
  load_client
  official_tracks = get_official_tracks
  remix_tracks = get_remix_tracks
  tracks = official_tracks.map { |track| track_official_data(track) }
  tracks += remix_tracks.map { |track| track_remix_data(track) }
  tracks.to_json
end

# Helpers

def load_client
  @client = Soundcloud.new(client_id: ENV['SOUNDCLOUD_CLIENT_ID'])
end

def get_official_tracks
  playlist = @client.get("/playlists/#{ENV['SOUNDCLOUD_PLAYLIST_ID']}")
  playlist.tracks
end

def get_remix_tracks
  playlist = @client.get("/playlists/#{ENV['SOUNDCLOUD_REMIX_PLAYLIST_ID']}")
  playlist.tracks
end

def track_official_data(track)
  track_generic_data(track).merge({
    artist: 'Kanye West',
    type: 'official',
  })
end

def track_remix_data(track)
  track_generic_data(track).merge({
    artist: track.user.username,
    type: 'remix',
  })
end

def track_generic_data(track)
  {
    id: track.id,
    title: track.title,
    duration: track.duration,
    artwork_url: track_artwork_url(track),
    stream_url: "#{track.stream_url}?client_id=#{ENV['SOUNDCLOUD_CLIENT_ID']}",
    permalink_url: track.permalink_url,
    source: 'SoundCloud',
    uploader: track.user.username,
    streamable: track.streamable,
  }
end

def track_artwork_url(track)
  return url('/images/album_art_placeholder.jpg') if track.artwork_url.blank?
  track.id == 239909100 ? url('/images/album_art_facts.jpg') : track.artwork_url.gsub('large', 't500x500')
end
