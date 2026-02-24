class ExportsController < ApplicationController
  CSV_CONTENT_TYPE = "text/csv; charset=utf-8".freeze
  CSV_HEADER = %w[
    record_id
    submitted_at_utc
    user_email
    company_name
    product_name
    quantity
  ].freeze

  before_action :require_sign_in

  def records
    records = filtered_records

    send_data(
      build_csv(records),
      filename: export_filename(from_date: parsed_from_date, to_date: parsed_to_date),
      type: CSV_CONTENT_TYPE
    )
  end

  private

  def filtered_records
    UtcDateRangeFilter.apply(
      visible_records_scope,
      from_date: parsed_from_date,
      to_date: parsed_to_date
    )
  end

  def visible_records_scope
    policy = RecordAccessPolicy.new(current_user)
    policy.visible_records(Record.includes(:user).order(:submitted_at_utc, :id))
  end

  def parsed_from_date
    @parsed_from_date ||= UtcDateRangeFilter.parse(params[:from_date])
  end

  def parsed_to_date
    @parsed_to_date ||= UtcDateRangeFilter.parse(params[:to_date])
  end

  def build_csv(records)
    rows = [CSV_HEADER]
    records.each do |record|
      rows << [
        record.record_id,
        record.submitted_at_utc&.utc&.strftime("%Y-%m-%d %H:%M:%S UTC"),
        record.user&.email,
        record.company_name,
        record.product_name,
        record.quantity
      ]
    end

    rows.map { |row| row.map { |cell| csv_escape(cell) }.join(",") }.join("\n")
  end

  def csv_escape(value)
    string_value = value.to_s
    escaped = string_value.gsub("\"", "\"\"")
    "\"#{escaped}\""
  end

  def export_filename(from_date:, to_date:)
    parts = []
    parts << "from-#{from_date.iso8601}" if from_date
    parts << "to-#{to_date.iso8601}" if to_date
    suffix = parts.any? ? parts.join("_") : "all"
    "records_#{suffix}.csv"
  end
end
