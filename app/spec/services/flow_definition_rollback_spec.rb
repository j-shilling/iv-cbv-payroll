require "rails_helper"

RSpec.describe FlowDefinitionRollback do
  let(:objective) { create(:verification_objective) }

  it "rolls back to the latest deprecated definition" do
    target = create(:flow_definition, verification_objective: objective, status: :deprecated, version: 1)
    current = create(:flow_definition, verification_objective: objective, status: :active, version: 2)

    result = described_class.new(objective).rollback!

    expect(result.success?).to be(true)
    expect(target.reload).to be_active
    expect(current.reload).to be_deprecated
  end
end
