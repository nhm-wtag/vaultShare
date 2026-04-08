class AssetsController < ApplicationController
  before_action :set_context
  before_action :set_asset, only: [:show, :edit, :update, :destroy, :download, :share, :revoke_share, :remove_file]

  def show
    authorize @asset
    @comments = @asset.comments.includes(:user)
    @comment = Comment.new
  end

  def new
    @asset = @collection.assets.build
    authorize @asset
  end

  def create
    @asset = @collection.assets.build(asset_params)
    authorize @asset
    if @asset.save
      ActivityLog.create!(user: current_user, asset: @asset, action: "upload")
      redirect_to library_collection_asset_path(@library, @collection, @asset),
                  notice: "Asset uploaded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @asset
  end

  def update
    authorize @asset
    if @asset.update(asset_params)
      ActivityLog.create!(user: current_user, asset: @asset, action: "update")
      redirect_to library_collection_asset_path(@library, @collection, @asset),
                  notice: "Asset updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @asset
    @asset.destroy
    redirect_to library_collection_path(@library, @collection), notice: "Asset deleted."
  end

  def download
    authorize @asset
    file = @asset.files.first
    return redirect_to library_collection_asset_path(@library, @collection, @asset),
                        alert: "No file attached." unless file&.attached?

    ActivityLog.create!(user: current_user, asset: @asset, action: "download")
    redirect_to rails_blob_path(file, disposition: "attachment")
  end

  def share
    authorize @asset, :update?
    expires_in = case params[:expires_in]
                 when "1"  then 1.day
                 when "30" then 30.days
                 else 7.days
                 end
    @asset.generate_share_token!(expires_in: expires_in)
    redirect_to library_collection_asset_path(@library, @collection, @asset),
                notice: "Share link generated."
  end

  def revoke_share
    authorize @asset, :update?
    @asset.revoke_share_token!
    redirect_to library_collection_asset_path(@library, @collection, @asset),
                notice: "Share link revoked."
  end

  def remove_file
    authorize @asset, :update?
    blob = ActiveStorage::Blob.find_signed(params[:signed_id])
    @asset.files.attachments.find_by(blob: blob)&.purge
    redirect_to edit_library_collection_asset_path(@library, @collection, @asset),
                notice: "File removed."
  end

  private

  def set_context
    @library = Library.find(params[:library_id])
    @collection = @library.collections.find(params[:collection_id])
  end

  def set_asset
    @asset = @collection.assets.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:title, :description, files: [])
  end
end
