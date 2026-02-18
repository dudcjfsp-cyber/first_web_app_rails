require "test_helper"

class InputMessageValidatorTest < ActiveSupport::TestCase
  test "T3 returns number error for non numeric quantity" do
    result = InputMessageValidator.call("ABC 제품1 열개")

    assert_not result[:success]
    assert_equal InputMessageParser::NUMBER_ERROR, result[:error_code]
  end

  test "T4 returns number error for decimal quantity" do
    result = InputMessageValidator.call("ABC 제품1 10.5")

    assert_not result[:success]
    assert_equal InputMessageParser::NUMBER_ERROR, result[:error_code]
  end

  test "T5 returns format error for company name with spaces" do
    result = InputMessageValidator.call("AB C 제품1 10")

    assert_not result[:success]
    assert_equal InputMessageParser::FORMAT_ERROR, result[:error_code]
  end

  test "T6 returns format error when overall input is broken" do
    result = InputMessageValidator.call("ABC 제품1")

    assert_not result[:success]
    assert_equal InputMessageParser::FORMAT_ERROR, result[:error_code]
  end

  test "T7 trims redundant spaces" do
    result = InputMessageValidator.call(" ABC   제품1   10 ")

    assert result[:success]
    assert_equal "ABC", result.dig(:data, :company_name)
    assert_equal [ { product_name: "제품1", quantity: 10 } ], result.dig(:data, :items)
  end

  test "T15 returns format error when company name exceeds 30 chars" do
    result = InputMessageValidator.call("#{"A" * 31} 제품1 10")

    assert_not result[:success]
    assert_equal InputMessageParser::FORMAT_ERROR, result[:error_code]
  end

  test "T16 returns format error when company name has forbidden sheet chars" do
    result = InputMessageValidator.call("AB[C 제품1 10")

    assert_not result[:success]
    assert_equal InputMessageParser::FORMAT_ERROR, result[:error_code]
  end

  test "T18 normalizes company name to uppercase" do
    result = InputMessageValidator.call("abc 제품1 10")

    assert result[:success]
    assert_equal "ABC", result.dig(:data, :company_name)
  end
end
