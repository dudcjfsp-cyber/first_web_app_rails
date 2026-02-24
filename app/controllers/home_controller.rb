require "securerandom"

class HomeController < ApplicationController
  before_action :require_sign_in

  def index
    @from_date_value = params[:from_date].to_s
    @to_date_value = params[:to_date].to_s

    @records = filtered_records
    @request_id = SecureRandom.uuid
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
    RecordAccessPolicy.new(current_user).visible_records(Record.order(:submitted_at_utc, :id))
  end

  def parsed_from_date
    @parsed_from_date ||= UtcDateRangeFilter.parse(@from_date_value)
  end

  def parsed_to_date
    @parsed_to_date ||= UtcDateRangeFilter.parse(@to_date_value)
  end
end
