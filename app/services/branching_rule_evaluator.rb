class BranchingRuleEvaluator
  Result = Struct.new(:branch_key, :matched_rule, :matched_conditions, :reason, keyword_init: true)

  def initialize(definition_snapshot:, verification_request:, logger: Rails.logger)
    @definition_snapshot = definition_snapshot
    @verification_request = verification_request
    @logger = logger
  end

  def evaluate
    rules = Array(@definition_snapshot["branching"]) 
    sorted_rules = rules.sort_by { |rule| [rule.fetch("priority", 999_999), rule.fetch("key", "")] }

    sorted_rules.each do |rule|
      conditions = Array(rule["conditions"])
      next unless conditions.all? { |condition| condition_met?(condition) }

      matched_conditions = conditions.map { |condition| describe_condition_match(condition) }
      log_decision("matched_rule", rule:, matched_conditions:)
      return Result.new(branch_key: rule["branch"], matched_rule: rule["key"], matched_conditions:, reason: "matched_rule")
    end

    fallback = @definition_snapshot.dig("completion", "fallback_branch") || "default"
    log_decision("fallback", fallback_branch: fallback)
    Result.new(branch_key: fallback, matched_rule: nil, matched_conditions: [], reason: "fallback")
  end

  private

  def condition_met?(condition)
    step = @verification_request.verification_steps.find { |row| row.step_key == condition["step_key"] }
    return false unless step

    expected_value = condition["equals"]
    step.payload[condition["field"]] == expected_value
  end

  def describe_condition_match(condition)
    {
      "step_key" => condition["step_key"],
      "field" => condition["field"],
      "expected" => condition["equals"]
    }
  end

  def log_decision(reason, extra = {})
    @logger.info("BranchingRuleEvaluator decision", {
      verification_request_id: @verification_request.id,
      reason:,
      **extra
    })
  end
end
