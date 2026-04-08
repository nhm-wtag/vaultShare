class ActivityLogsController < ApplicationController
  def index
    @logs = ActivityLog
              .includes(:user, asset: { collection: :library })
              .order(created_at: :desc)
              .limit(100)
    @logs = @logs.where(user: current_user) unless current_user.admin?
  end
end
