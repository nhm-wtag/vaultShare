class SharedAssetsController < ApplicationController
  skip_before_action :authenticate_user!
  layout "devise"

  def show
    @asset = Asset.find_by(share_token: params[:token])

    if @asset.nil?
      render plain: "This link is invalid.", status: :not_found and return
    end

    unless @asset.share_link_active?
      render plain: "This share link has expired.", status: :gone and return
    end

    @collection = @asset.collection
    @library    = @collection.library
  end
end
