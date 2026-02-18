require "test_helper"

class InputMessageParserTest < ActiveSupport::TestCase
  test "parses a single product row" do
    result = InputMessageParser.call("ABC 제품1 10")

    assert result[:success]
    assert_nil result[:error_code]
    assert_equal "ABC", result.dig(:data, :company_name)
    assert_equal [ { product_name: "제품1", quantity: 10 } ], result.dig(:data, :items)
  end

  test "parses multiple products" do
    result = InputMessageParser.call("XYZ 제품A 5 제품B 15")

    assert result[:success]
    assert_equal "XYZ", result.dig(:data, :company_name)
    assert_equal(
      [
        { product_name: "제품A", quantity: 5 },
        { product_name: "제품B", quantity: 15 }
      ],
      result.dig(:data, :items)
    )
  end

  test "trims redundant whitespace" do
    result = InputMessageParser.call("  ABC   제품1   10  ")

    assert result[:success]
    assert_equal "ABC", result.dig(:data, :company_name)
    assert_equal [ { product_name: "제품1", quantity: 10 } ], result.dig(:data, :items)
  end

  test "returns format error when quantity is missing" do
    result = InputMessageParser.call("ABC 제품1")

    assert_not result[:success]
    assert_equal InputMessageParser::FORMAT_ERROR, result[:error_code]
  end

  test "returns number error when quantity is not numeric" do
    result = InputMessageParser.call("ABC 제품1 열개")

    assert_not result[:success]
    assert_equal InputMessageParser::NUMBER_ERROR, result[:error_code]
  end

  test "returns format error when product quantity pairs are broken" do
    result = InputMessageParser.call("ABC 제품1 10 제품2")

    assert_not result[:success]
    assert_equal InputMessageParser::FORMAT_ERROR, result[:error_code]
  end
end
