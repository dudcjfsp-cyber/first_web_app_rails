module ServiceResult
  private

  def success(payload = nil)
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
