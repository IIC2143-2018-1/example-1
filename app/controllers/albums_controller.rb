class AlbumsController < ApplicationController
  before_action :set_artist
  before_action :set_artist_album, only: %i[show edit update destroy]

  def index
    @albums = @artist.albums.all
  end

  def show
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(album_params)

    respond_to do |format|
      if @album.save
        format.html {
          redirect_to artist_album_path(@artist, @album),
          notice: 'Album was successfully created.'
        }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { render :new }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @album.update(album_params)
        format.html {
          redirect_to artist_album_path(@artist, @album),
          notice: 'Album was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { render :edit }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @album.destroy
    respond_to do |format|
      format.html {
        redirect_to artist_albums_path(@artist),
        notice: 'Album was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  private

    def set_artist
      @artist = Artist.find(params[:artist_id])
    end

    def set_artist_album
      @album = @artist.albums.find_by!(id: params[:id]) if @artist
    end

    def album_params
      params.require(:album).permit(:name, :year, :artist_id)
    end
end