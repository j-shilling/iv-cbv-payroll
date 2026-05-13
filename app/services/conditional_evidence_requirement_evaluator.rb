class ConditionalEvidenceRequirementEvaluator
  Result = Struct.new(:required_evidence, :missing_evidence, keyword_init: true)

  def initialize(definition_snapshot:, verification_request:)
    @definition_snapshot = definition_snapshot
    @verification_request = verification_request
  end

  def evaluate
    required = Array(@definition_snapshot.dig("evidence", "required")).dup
    conditional = Array(@definition_snapshot.dig("evidence", "conditional"))

    conditional.each do |rule|
      next unless evidence_missing?(rule["if_missing"])

      required.concat(Array(rule["then_require"]))
    end

    required.uniq!
    missing = required.reject { |type| has_evidence?(type) }
    Result.new(required_evidence: required, missing_evidence: missing)
  end

  private

  def evidence_missing?(type)
    !has_evidence?(type)
  end

  def has_evidence?(type)
    @verification_request.verification_evidence.any? { |row| row.evidence_type == type }
  end
end
