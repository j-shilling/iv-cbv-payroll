require "rails_helper"

RSpec.describe "Flow definition contract compatibility" do
  it "accepts branching and conditional evidence for v1 and v2 definitions" do
    validator = FlowDefinitionValidator.new

    v1 = StudentEnrollmentVerificationDefinition.payload
    v2 = v1.deep_dup
    v2["branching"] = [
      { "key" => "doc_missing", "priority" => 1, "branch" => "attestation_path", "conditions" => [] }
    ]
    v2["evidence"]["conditional"] = [
      { "if_missing" => "enrollment_document", "then_require" => ["attestation_statement"] }
    ]

    expect(validator.validate(v1)).to be_empty
    expect(validator.validate(v2)).to be_empty
  end
end
