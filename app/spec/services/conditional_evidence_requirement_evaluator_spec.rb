require "rails_helper"

RSpec.describe ConditionalEvidenceRequirementEvaluator do
  let(:objective) { create(:verification_objective, objective_key: "income") }
  let(:definition) { create(:flow_definition, :active, verification_objective: objective) }
  let(:verification_request) do
    create(:verification_request, verification_objective: objective, flow_definition: definition, definition_snapshot: snapshot)
  end
  let(:snapshot) do
    {
      "evidence" => {
        "required" => ["paystub"],
        "conditional" => [
          { "if_missing" => "paystub", "then_require" => ["attestation_statement"] }
        ]
      }
    }
  end

  it "requires fallback attestation when primary document is missing" do
    result = described_class.new(definition_snapshot: snapshot, verification_request:).evaluate

    expect(result.required_evidence).to include("attestation_statement")
    expect(result.missing_evidence).to include("attestation_statement")
  end
end
