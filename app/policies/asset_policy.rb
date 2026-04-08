class AssetPolicy < ApplicationPolicy
  def show?     = CollectionPolicy.new(user, record.collection).show?
  def create?   = user.admin? || user.contributor?
  def new?      = create?
  def update?   = user.admin? || record.collection.library.owned_by?(user)
  def edit?     = update?
  def destroy?  = update?
  def download? = show?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(collection: :library)
           .merge(LibraryPolicy::Scope.new(user, Library).resolve)
    end
  end
end
