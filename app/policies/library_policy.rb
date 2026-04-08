class LibraryPolicy < ApplicationPolicy
  def index?  = true
  def show?   = user.admin? || record.shared? || record.owned_by?(user)
  def create? = user.admin? || user.contributor?
  def new?    = create?
  def update? = user.admin? || record.owned_by?(user)
  def edit?   = update?
  def destroy? = user.admin? || record.owned_by?(user)

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user).or(scope.where(visibility: :shared))
      end
    end
  end
end
