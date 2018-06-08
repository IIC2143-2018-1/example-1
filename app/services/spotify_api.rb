class SpotifyApi
  include HTTParty
  base_uri 'https://api.spotify.com/v1'

  def initialize
    credentials = "#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}"
    auth = 'Basic ' + Base64.encode64(credentials).chomp.gsub("\n",'')
    response = self.class.post(
      'https://accounts.spotify.com/api/token',
      {
        headers: { 'Authorization' => auth },
        body: {grant_type: 'client_credentials'}
      }
    )
    @token = response['access_token']
  end

  def auth_header
    {'Authorization' => "Bearer #{@token}"}
  end

  def search_artists(name)
    self.class.get(
      "/search?q=#{name}&type=artist",
      { headers: auth_header }
    ).to_h['artists']['items']
    # TAREA PARA LA CASA: Manejar errores
  end

  def get_artist(id)
    self.class.get(
      "/artists/#{id}",
      { headers: auth_header }
    ).to_h
  end
end