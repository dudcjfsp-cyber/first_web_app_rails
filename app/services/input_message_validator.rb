class InputMessageValidator
  FORBIDDEN_SHEET_CHARS = /[\[\]:*?\/\\]/.freeze

  def self.call(raw_text)
    new(raw_text).call
  end

  def initialize(raw_text)
    @raw_text = raw_text
  end

  def call
    parsed = InputMessageParser.call(@raw_text)
    return parsed unless parsed[:success]

    company_name = parsed.dig(:data, :company_name).to_s.strip
    return failure(InputMessageParser::FORMAT_ERROR) if invalid_company_name?(company_name)

    normalized_company_name = company_name.upcase
    success(
      company_name: normalized_company_name,
      items: parsed.dig(:data, :items)
    )
  end

  private

  def invalid_company_name?(company_name)
    company_name.empty? ||
      company_name.length > 30 ||
      company_name.match?(FORBIDDEN_SHEET_CHARS)
  end

  def success(payload)
    {
      success: true,
      data: payload,
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
