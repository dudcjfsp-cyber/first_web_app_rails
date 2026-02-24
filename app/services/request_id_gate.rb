require "set"

class RequestIdGate
  VALIDATION_ERROR = "VALIDATION_ERROR".freeze
  DUPLICATE_REQUEST = "DUPLICATE_REQUEST".freeze

  include ServiceResult

  def self.run(request_id:, &block)
    new(request_id).run(&block)
  end

  def self.clear!
    store_mutex.synchronize { claimed_request_ids.clear }
  end

  def initialize(request_id)
    @request_id = request_id.to_s.strip
  end

  def run
    return failure(VALIDATION_ERROR) if @request_id.empty?
    return failure(DUPLICATE_REQUEST) unless claim_request_id

    payload = block_given? ? yield : nil
    success(payload)
  end

  private

  def claim_request_id
    self.class.store_mutex.synchronize do
      return false if self.class.claimed_request_ids.include?(@request_id)

      self.class.claimed_request_ids << @request_id
      true
    end
  end

  class << self
    def claimed_request_ids
      @claimed_request_ids ||= Set.new
    end

    def store_mutex
      @store_mutex ||= Mutex.new
    end
  end
end
