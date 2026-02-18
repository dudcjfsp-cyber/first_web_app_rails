require "securerandom"

class HomeController < ApplicationController
  def index
    policy = RecordAccessPolicy.new(current_user)
    @records = policy.visible_records(Record.order(:submitted_at_utc, :id))
    @request_id = SecureRandom.uuid
  end
end
