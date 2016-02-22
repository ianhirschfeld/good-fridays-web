require 'dotenv'
require 'json'
require 'sinatra'
require 'soundcloud'

Dotenv.load

get '/tracks.json' do
  tracks = get_tracks
  tracks.map do |track|
    if track.stream_url
      {
        id: track.id,
        title: track.title,
        duration: track.duration,
        artwork_url: track.id == 239909100 ? url('/images/album_art_facts.jpg') : track.artwork_url.gsub('large', 't500x500'),
        stream_url: "#{track.stream_url}?client_id=#{ENV['SOUNDCLOUD_CLIENT_ID']}",
        source: 'SoundCloud',
        uploader: track.user.username,
      }
    end
  end.compact.to_json
end

get '/tracks_v2.json' do
  tracks = get_tracks
  tracks.map do |track|
    {
      id: track.id,
      title: track.title,
      duration: track.duration,
      artwork_url: track.id == 239909100 ? url('/images/album_art_facts.jpg') : track.artwork_url.gsub('large', 't500x500'),
      stream_url: "#{track.stream_url}?client_id=#{ENV['SOUNDCLOUD_CLIENT_ID']}",
      permalink_url: track.permalink_url,
      source: 'SoundCloud',
      uploader: track.user.username,
      streamable: track.streamable,
    }
  end.to_json
end

def get_tracks
  client = Soundcloud.new(client_id: ENV['SOUNDCLOUD_CLIENT_ID'])
  playlist = client.get("/playlists/#{ENV['SOUNDCLOUD_PLAYLIST_ID']}")
  playlist.tracks
end
