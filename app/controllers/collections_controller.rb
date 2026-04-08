class CollectionsController < ApplicationController
  before_action :set_library
  before_action :set_collection, only: [:show, :destroy]

  def show
    authorize @collection
    @assets = @collection.assets.includes(files_attachments: :blob).order(created_at: :desc)
  end

  def new
    @collection = @library.collections.build
    authorize @collection
  end

  def create
    @collection = @library.collections.build(collection_params)
    authorize @collection
    if @collection.save
      redirect_to library_collection_path(@library, @collection), notice: "Collection created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @collection
    @collection.destroy
    redirect_to @library, notice: "Collection deleted."
  end

  private

  def set_library
    @library = Library.find(params[:library_id])
  end

  def set_collection
    @collection = @library.collections.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name)
  end
end
