class FlowDefinitionPreviewHarness
  Result = Struct.new(:success?, :errors, :step_keys, keyword_init: true)

  def initialize(definition_payload, actor_role: "caseworker")
    @definition_payload = definition_payload
    @actor_role = actor_role
  end

  def preview
    errors = FlowDefinitionValidator.new.validate(@definition_payload)
    role_errors = role_specific_errors
    all_errors = errors + role_errors

    Result.new(
      success?: all_errors.empty?,
      errors: all_errors,
      step_keys: Array(@definition_payload["steps"]).map { |step| step["key"] }
    )
  end

  private

  def role_specific_errors
    return [] if %w[caseworker admin].include?(@actor_role)

    [FlowDefinitionValidator::ValidationError.new(path: "preview.actor_role", message: "must be caseworker or admin")]
  end
end
