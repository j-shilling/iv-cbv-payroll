require "rails_helper"

RSpec.describe BranchingRuleEvaluator do
  let(:objective) { create(:verification_objective, objective_key: "income") }
  let(:definition) { create(:flow_definition, :active, verification_objective: objective) }
  let(:verification_request) do
    create(:verification_request, verification_objective: objective, flow_definition: definition, definition_snapshot: snapshot)
  end
  let(:snapshot) do
    {
      "branching" => [
        { "key" => "z_rule", "priority" => 2, "branch" => "secondary", "conditions" => [ { "step_key" => "attestation", "field" => "doc_uploaded", "equals" => false } ] },
        { "key" => "a_rule", "priority" => 1, "branch" => "primary", "conditions" => [ { "step_key" => "attestation", "field" => "doc_uploaded", "equals" => false } ] }
      ],
      "completion" => { "fallback_branch" => "manual_review" }
    }
  end

  it "uses deterministic precedence by priority and key" do
    create(:verification_step, verification_request:, step_key: "attestation", payload: { "doc_uploaded" => false })

    result = described_class.new(definition_snapshot: snapshot, verification_request:).evaluate

    expect(result.branch_key).to eq("primary")
    expect(result.matched_rule).to eq("a_rule")
  end
end
