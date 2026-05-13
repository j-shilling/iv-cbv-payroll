class FlowDefinitionValidator
  ValidationError = Struct.new(:path, :message, keyword_init: true)

  def validate(payload)
    @errors = []
    validate_root(payload)
    @errors
  end

  private

  def validate_root(payload)
    expect_hash(payload, "")
    return if @errors.any?

    validate_metadata(payload["metadata"], "metadata")
    validate_steps(payload["steps"], "steps")
    validate_branching(payload["branching"], "branching")
    validate_evidence(payload["evidence"], "evidence")
    validate_completion(payload["completion"], "completion")
    validate_security(payload["security"], "security")
  end

  def validate_metadata(value, path)
    expect_hash(value, path)
    require_string(value, "name", path)
    require_string(value, "objective_key", path)
  end

  def validate_steps(value, path)
    expect_array(value, path)
    return unless value.is_a?(Array)

    value.each_with_index do |step, idx|
      expect_hash(step, "#{path}[#{idx}]")
      next unless step.is_a?(Hash)

      require_string(step, "key", "#{path}[#{idx}]")
      fields_path = "#{path}[#{idx}].fields"
      expect_array(step["fields"], fields_path)
      next unless step["fields"].is_a?(Array)

      step["fields"].each_with_index do |field, field_idx|
        expect_hash(field, "#{fields_path}[#{field_idx}]")
        next unless field.is_a?(Hash)

        require_string(field, "name", "#{fields_path}[#{field_idx}]")
        required = field["required"]
        add_error("#{fields_path}[#{field_idx}].required", "must be a boolean") if required != true && required != false
      end
    end
  end

  def validate_branching(value, path)
    expect_array(value, path)
    return unless value.is_a?(Array)

    value.each_with_index do |rule, idx|
      expect_hash(rule, "#{path}[#{idx}]")
      next unless rule.is_a?(Hash)

      require_string(rule, "key", "#{path}[#{idx}]")
      require_string(rule, "branch", "#{path}[#{idx}]")
      priority = rule["priority"]
      add_error("#{path}[#{idx}].priority", "must be an integer") unless priority.is_a?(Integer)

      expect_array(rule["conditions"], "#{path}[#{idx}].conditions")
    end
  end

  def validate_evidence(value, path)
    expect_hash(value, path)
    return unless value.is_a?(Hash)

    expect_array(value["required"], "#{path}.required")
    conditional = value["conditional"]
    return if conditional.nil?

    expect_array(conditional, "#{path}.conditional")
    return unless conditional.is_a?(Array)

    conditional.each_with_index do |rule, idx|
      expect_hash(rule, "#{path}.conditional[#{idx}]")
      next unless rule.is_a?(Hash)

      require_string(rule, "if_missing", "#{path}.conditional[#{idx}]")
      expect_array(rule["then_require"], "#{path}.conditional[#{idx}].then_require")
    end
  end

  def validate_completion(value, path)
    expect_hash(value, path)
    return unless value.is_a?(Hash)

    require_string(value, "strategy", path)
  end

  def validate_security(value, path)
    expect_hash(value, path)
    return unless value.is_a?(Hash)

    encryption = value["encryption_required"]
    add_error("#{path}.encryption_required", "must be a boolean") if encryption != true && encryption != false
  end

  def expect_hash(value, path)
    add_error(path, "must be an object") unless value.is_a?(Hash)
  end

  def expect_array(value, path)
    add_error(path, "must be an array") unless value.is_a?(Array)
  end

  def require_string(hash, key, path)
    value = hash[key]
    add_error("#{path}.#{key}", "must be a string") unless value.is_a?(String) && value.present?
  end

  def add_error(path, message)
    @errors << ValidationError.new(path:, message:)
  end
end
