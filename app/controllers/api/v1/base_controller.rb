module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_user!

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: "Forbidden" }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not found" }, status: :not_found
      end

      private

      def current_user
        warden.authenticate(scope: :user)
      end

      def warden
        request.env["warden"]
      end

      def authenticate_user!
        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
      end
    end
  end
end
