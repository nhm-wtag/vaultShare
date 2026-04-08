class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { viewer: "viewer", contributor: "contributor", admin: "admin" }, default: :viewer

  def admin?
    role == "admin"
  end

  def contributor?
    role == "contributor" || role == "admin"
  end
end
