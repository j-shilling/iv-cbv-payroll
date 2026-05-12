class Api::V1::VerificationRequestsController < ApplicationController
  skip_forgery_protection
  wrap_parameters false
  before_action :authenticate

  def create
    cbv_applicant = CbvApplicant.find(params.require(:cbv_applicant_id))
    result = VerificationRequestCreator.call(
      cbv_applicant: cbv_applicant,
      objective_key: params.require(:objective_key),
      case_identifier: params.require(:case_identifier),
      due_date: params[:due_date],
      reminder_cadence: params[:reminder_cadence],
      note: params[:note]
    )

    unless result.success?
      return render json: { errors: result.errors }, status: :unprocessable_content
    end

    render json: { id: result.verification_request.id, status: result.verification_request.status }, status: :created
  end

  def issue_entry_token
    verification_request = VerificationRequest.find(params[:id])
    token = VerificationRequestEntryTokenService.generate(verification_request)

    verification_request.sent! if verification_request.created?

    render json: { token: token, expires_at: verification_request.reload.entry_token_expires_at.iso8601 }
  end

  def exchange_entry_token
    verification_request = VerificationRequestEntryTokenService.exchange(params.require(:token))
    return head :unauthorized unless verification_request

    verification_request.in_progress! if verification_request.sent?
    render json: { verification_request_id: verification_request.id, status: verification_request.status }
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      @current_user = User.find_by_access_token(token)
    end
  end
end
