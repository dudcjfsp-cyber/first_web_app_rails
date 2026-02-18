class LocalMessageIngestor
  def self.call(raw_text:, request_id:, user:)
    new(raw_text: raw_text, request_id: request_id, user: user).call
  end

  def initialize(raw_text:, request_id:, user:)
    @raw_text = raw_text
    @request_id = request_id
    @user = user
  end

  def call
    request_gate = RequestIdGate.run(request_id: @request_id)
    return request_gate unless request_gate[:success]

    validation = InputMessageValidator.call(@raw_text)
    return validation unless validation[:success]

    records = persist_records!(validation[:data])
    success(records)
  rescue ActiveRecord::ActiveRecordError
    failure("STORAGE_ERROR")
  end

  private

  def persist_records!(validated_data)
    company_name = validated_data[:company_name]
    items = validated_data[:items]

    Record.transaction do
      items.map do |item|
        Record.create!(
          request_id: @request_id,
          user: @user,
          submitted_at_utc: Time.current.utc,
          company_name: company_name,
          product_name: item[:product_name],
          quantity: item[:quantity]
        )
      end
    end
  end

  def success(records)
    {
      success: true,
      data: records,
      error_code: nil
    }
  end

  def failure(error_code)
    {
      success: false,
      data: nil,
      error_code: error_code
    }
  end
end
