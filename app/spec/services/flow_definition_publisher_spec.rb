require "rails_helper"

RSpec.describe FlowDefinitionPublisher do
  let(:objective) { create(:verification_objective) }

  let(:valid_payload) do
    {
      "metadata" => { "name" => "Income verification", "objective_key" => "income" },
      "steps" => [
        { "key" => "collect_docs", "fields" => [ { "name" => "upload", "required" => true } ] }
      ],
      "branching" => [],
      "evidence" => { "required" => ["paystub"] },
      "completion" => { "strategy" => "all_required_steps" },
      "security" => { "encryption_required" => true }
    }
  end

  it "publishes, increments version, and deprecates prior active definition" do
    active = create(:flow_definition, verification_objective: objective, status: :active, version: 1, definition_payload: valid_payload)
    draft = create(:flow_definition, verification_objective: objective, status: :draft, version: 2, definition_payload: valid_payload)

    result = described_class.new(draft).publish

    expect(result.success?).to be(true)
    expect(draft.reload).to be_active
    expect(draft.version).to eq(3)
    expect(active.reload).to be_deprecated
    expect(FlowDefinitionAuditEvent.where(event_type: "published", flow_definition: draft)).to exist
  end

  it "records validation failures with exact path" do
    draft = create(:flow_definition, verification_objective: objective, definition_payload: valid_payload.deep_dup)
    draft.definition_payload["steps"][0]["fields"][0]["required"] = "not_bool"

    result = described_class.new(draft).publish

    expect(result.success?).to be(false)
    expect(result.errors.first.path).to eq("steps[0].fields[0].required")
    expect(draft.reload).to be_draft
    expect(FlowDefinitionAuditEvent.where(event_type: "validation_failed", flow_definition: draft)).to exist
  end
end
