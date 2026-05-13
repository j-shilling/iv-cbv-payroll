class VerificationBranchDecisionRecorder
  EVENT_TYPE = "branch_decision_recorded".freeze

  def initialize(verification_request:)
    @verification_request = verification_request
  end

  def record!(branch_result:, evidence_result:)
    @verification_request.verification_events.create!(
      event_type: EVENT_TYPE,
      payload: {
        "branch_key" => branch_result.branch_key,
        "matched_rule" => branch_result.matched_rule,
        "matched_conditions" => branch_result.matched_conditions,
        "reason" => branch_result.reason,
        "required_evidence" => evidence_result.required_evidence,
        "missing_evidence" => evidence_result.missing_evidence
      },
      occurred_at: Time.current
    )
  end
end
