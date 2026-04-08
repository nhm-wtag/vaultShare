class CommentPolicy < ApplicationPolicy
  def create?  = user.present?
  def destroy? = user.admin? || record.user == user
end
