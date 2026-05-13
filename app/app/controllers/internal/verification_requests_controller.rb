module Internal
  class VerificationRequestsController < ApplicationController
    before_action :ensure_internal_environment
    before_action :set_verification_request, only: %i[show branch_debug]

    def show; end

    def branch_debug
      branch_result = BranchingRuleEvaluator.new(
        definition_snapshot: @verification_request.definition_snapshot,
        verification_request: @verification_request
      ).evaluate

      evidence_result = ConditionalEvidenceRequirementEvaluator.new(
        definition_snapshot: @verification_request.definition_snapshot,
        verification_request: @verification_request
      ).evaluate

      if ActiveModel::Type::Boolean.new.cast(params[:persist])
        VerificationBranchDecisionRecorder.new(verification_request: @verification_request)
          .record!(branch_result:, evidence_result:)
      end

      render json: {
        verification_request_id: @verification_request.id,
        branch: {
          branch_key: branch_result.branch_key,
          matched_rule: branch_result.matched_rule,
          matched_conditions: branch_result.matched_conditions,
          reason: branch_result.reason
        },
        evidence: {
          required: evidence_result.required_evidence,
          missing: evidence_result.missing_evidence
        },
        latest_decision_event: @verification_request.verification_events
          .where(event_type: VerificationBranchDecisionRecorder::EVENT_TYPE)
          .order(occurred_at: :desc)
          .first
      }
    end

    private

    def set_verification_request
      @verification_request = VerificationRequest
        .includes(:verification_objective, :verification_steps, :verification_evidence, :verification_events)
        .find(params[:id])
    end

    def ensure_internal_environment
      raise ActionController::RoutingError, "Not Found" unless Rails.application.config.is_internal_environment
    end
  end
end
