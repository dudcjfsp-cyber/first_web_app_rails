require "date"

class UtcDateRangeFilter
  def self.apply(scope, from_date:, to_date:)
    new(scope, from_date: from_date, to_date: to_date).apply
  end

  def self.parse(value)
    return if value.blank?

    Date.iso8601(value.to_s)
  rescue ArgumentError
    nil
  end

  def initialize(scope, from_date:, to_date:)
    @scope = scope
    @from_date = from_date
    @to_date = to_date
  end

  def apply
    filtered = @scope
    filtered = filtered.where("submitted_at_utc >= ?", @from_date.beginning_of_day) if @from_date
    filtered = filtered.where("submitted_at_utc <= ?", @to_date.end_of_day) if @to_date
    filtered
  end
end
