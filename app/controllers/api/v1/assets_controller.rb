module Api
  module V1
    class AssetsController < BaseController
      def index
        collection = Collection.find(params[:collection_id])
        @assets = collection.assets.includes(files_attachments: :blob)
      end

      def update
        @asset = Asset.find(params[:id])
        authorize @asset
        if @asset.update(asset_params)
          ActivityLog.create!(user: current_user, asset: @asset, action: "update")
          render :update
        else
          render json: { errors: @asset.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def asset_params
        params.require(:asset).permit(:title, :description)
      end
    end
  end
end
