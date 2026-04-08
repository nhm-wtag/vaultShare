class DashboardController < ApplicationController
  def index
    accessible_libraries = policy_scope(Library)
    accessible_collections = Collection.where(library: accessible_libraries)

    @stats = {
      libraries: accessible_libraries.count,
      collections: accessible_collections.count,
      assets: Asset.where(collection: accessible_collections).count
    }

    @recent_libraries = accessible_libraries.order(created_at: :desc).limit(4)
    @recent_logs = ActivityLog
                     .where(user: current_user)
                     .includes(asset: { collection: :library })
                     .order(created_at: :desc)
                     .limit(8)
  end
end
