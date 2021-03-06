class EntriesController < ApplicationController

before_action :authenticate, only: [:edit, :index, :update, :destroy]

def index
  @entries= Entry.all
end

def notify
  if current_user.present?
  @email = current_user.email
  UserMailer.note_email(@email, @entry).deliver
  redirect_to :back
  else
  redirect_to login_path
  end
end

def show
  @entry = Entry.find(params[:id])
  @keywords = @entry.alchemy
  @array = @keywords.map { |kw| kw["text"] }

  #wiki
  # @wiki= Entry.wiki(@array[0])
  # @wiki_titles = @wiki.map { |title| title["title"] }
  # @wiki_snippet = @wiki.map { |snippet| snippet["snippet"] }
  #google
  @google= Entry.google(@array[0])
  @google_sorted = []
  @google.each do |result|
    begin
     @google_sorted << {
      title: result["title"],
      snippet: result["snippet"],
      image:  result["pagemap"]["cse_image"][0]["src"],
      link: result["link"]
     }
    rescue
    end
  end

  #souncloud
  @soundcloud = Entry.soundcloud(@array[0])

  #youtube
  @youtube = Entry.youtube(@array[0])
  #instagram
  # @instagram = Entry.instagram(@array[0])

  if params[:from_ajax]
    render 'show', layout: false
    return
  end

end

def keyword
  @entry = Entry.find(params[:id])
  @keywords = @entry.alchemy
  @array = @keywords.map { |kw| kw["text"] }
  @keyword = @array.index(params[:keyword])

  #wiki
  @wiki= Entry.wiki(@array[@keyword])
  @wiki_titles = @wiki.map { |title| title["title"] }
  @wiki_snippet = @wiki.map { |snippet| snippet["snippet"] }
  #google
  @google= Entry.google(@array[@keyword])
  @google_sorted = []
  @google.each do |result|
     @google_sorted << {
      title: result["title"],
      snippet: result["snippet"],
      image:  result["pagemap"]["cse_image"][0]["src"],
      link: result["link"]
    }
  end

  #souncloud
  @soundcloud = Entry.soundcloud(@array[@keyword])

  #youtube
  @youtube = Entry.youtube(@array[@keyword])
  #instagram
  # @instagram = Entry.instagram(@array[0])


end


def new
    @entry = Entry.new
end
def new2
    @entry = Entry.new
end

def create
    @entry = Entry.new(entry_params)
    if @entry.save
      respond_to do |format|
        format.html { redirect_to @entry }
        format.json { render json: @entry }
        format.js   { }
      end
    else
        redirect_to :new
    end
end

private
  def entry_params
    params.require(:entry).permit(:input, :number)
  end


end
