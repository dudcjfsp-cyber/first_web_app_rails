class InputMessageParser
  FORMAT_ERROR = "FORMAT_ERROR".freeze
  NUMBER_ERROR = "NUMBER_ERROR".freeze

  def self.call(raw_text)
    new(raw_text).call
  end

  def initialize(raw_text)
    @raw_text = raw_text.to_s
  end

  def call
    tokens = normalized_tokens
    return failure(FORMAT_ERROR) if invalid_structure?(tokens)

    company_name = tokens.first
    items = []

    tokens.drop(1).each_slice(2) do |product_name, quantity_token|
      return failure(FORMAT_ERROR) if product_name.nil? || quantity_token.nil?
      return failure(NUMBER_ERROR) unless integer_token?(quantity_token)

      items << {
        product_name: product_name,
        quantity: quantity_token.to_i
      }
    end

    success(
      company_name: company_name,
      items: items
    )
  end

  private

  def normalized_tokens
    @raw_text.strip.split(/\s+/).map(&:strip).reject(&:empty?)
  end

  def invalid_structure?(tokens)
    tokens.length < 3 || tokens.length.even?
  end

  def integer_token?(token)
    token.match?(/\A\d+\z/)
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
