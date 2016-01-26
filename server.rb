require 'dotenv'
require 'json'
require 'sinatra'
require 'soundcloud'

Dotenv.load

get '/tracks.json' do
  client = Soundcloud.new(client_id: ENV['SOUNDCLOUD_CLIENT_ID'])
  playlist = client.get("/playlists/#{ENV['SOUNDCLOUD_PLAYLIST_ID']}")
  tracks = playlist.tracks
  tracks.map do |track|
    {
      id: track.id,
      title: track.title,
      duration: track.duration,
      artwork_url: track.artwork_url.gsub('large', 't500x500'),
      stream_url: "#{track.stream_url}?client_id=#{ENV['SOUNDCLOUD_CLIENT_ID']}"
    }
  end.to_json
end
