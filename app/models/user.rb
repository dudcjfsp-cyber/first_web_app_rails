class User < ApplicationRecord
  has_many :records, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :auth_uid, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w[member admin] }
end
