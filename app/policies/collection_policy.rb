class CollectionPolicy < ApplicationPolicy
  def show?    = LibraryPolicy.new(user, record.library).show?
  def create?  = user.admin? || user.contributor?
  def new?     = create?
  def destroy? = user.admin? || record.library.owned_by?(user)

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:library).merge(LibraryPolicy::Scope.new(user, Library).resolve)
    end
  end
end
