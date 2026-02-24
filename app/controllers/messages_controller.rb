class MessagesController < ApplicationController
  before_action :require_sign_in

  def create
    result = LocalMessageIngestor.call(
      raw_text: params[:message],
      request_id: params[:request_id],
      user: current_user
    )

    if result[:success]
      flash[:notice] = "저장되었습니다."
    else
      flash[:alert] = error_message_for(result[:error_code])
    end

    redirect_to root_path
  end

  private

  def error_message_for(error_code)
    case error_code
    when InputMessageParser::NUMBER_ERROR
      "갯수는 숫자만 입력해주세요."
    when InputMessageParser::FORMAT_ERROR
      "데이터 입력이 불가능한 형식입니다"
    when RequestIdGate::VALIDATION_ERROR
      "request_id가 필요합니다."
    when RequestIdGate::DUPLICATE_REQUEST
      "이미 처리된 요청입니다."
    else
      "[데이터 입력 실패]"
    end
  end
end
