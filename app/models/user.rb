class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :libraries, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  enum :role, { viewer: "viewer", contributor: "contributor", admin: "admin" }, default: :viewer

  def admin?
    role == "admin"
  end

  def contributor?
    role == "contributor" || role == "admin"
  end
end
