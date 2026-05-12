require "rails_helper"

RSpec.describe FlowDefinition, type: :model do
  it "enforces uniqueness for objective version" do
    objective = create(:verification_objective)
    create(:flow_definition, verification_objective: objective, version: 3)

    duplicate = build(:flow_definition, verification_objective: objective, version: 3)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:verification_objective_id]).to include("has already been taken")
  end

  it "prevents payload changes when active" do
    flow_definition = create(:flow_definition, status: :active)

    flow_definition.definition_payload = { "steps" => [ { "key" => "changed" } ] }

    expect(flow_definition.save).to be(false)
    expect(flow_definition.errors[:base]).to include("Active flow definitions are immutable")
  end
end
