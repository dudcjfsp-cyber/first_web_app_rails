class RecordSheetIndex < ApplicationRecord
  belongs_to :record,
             primary_key: :record_id,
             foreign_key: :record_id,
             inverse_of: :record_sheet_index

  validates :record_id, presence: true, uniqueness: true
  validates :sheet_name, presence: true
  validates :row_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
