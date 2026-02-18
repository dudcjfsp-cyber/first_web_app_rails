require "securerandom"

class Record < ApplicationRecord
  belongs_to :user
  has_one :record_sheet_index,
          primary_key: :record_id,
          foreign_key: :record_id,
          dependent: :destroy,
          inverse_of: :record

  before_validation :assign_record_id, on: :create
  before_validation :assign_submitted_at_utc, on: :create

  validates :record_id, presence: true, uniqueness: true
  validates :request_id, presence: true
  validates :submitted_at_utc, presence: true
  validates :company_name, presence: true
  validates :product_name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true }

  private

  def assign_record_id
    self.record_id ||= SecureRandom.uuid
  end

  def assign_submitted_at_utc
    self.submitted_at_utc ||= Time.current.utc
  end
end
