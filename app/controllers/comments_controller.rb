class CommentsController < ApplicationController
  before_action :set_context

  def create
    @comment = @asset.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to library_collection_asset_path(@library, @collection, @asset)
        end
      end
    else
      redirect_to library_collection_asset_path(@library, @collection, @asset),
                  alert: "Comment could not be posted."
    end
  end

  def destroy
    @comment = @asset.comments.find(params[:id])
    authorize @comment
    @comment.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("comment_#{@comment.id}")
      end
      format.html do
        redirect_to library_collection_asset_path(@library, @collection, @asset)
      end
    end
  end

  private

  def set_context
    @library = Library.find(params[:library_id])
    @collection = @library.collections.find(params[:collection_id])
    @asset = @collection.assets.find(params[:asset_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
