require "rails_helper"

RSpec.describe VerificationDefinitionMetrics do
  it "builds dashboard metrics" do
    objective = create(:verification_objective)
    flow_definition = create(:flow_definition, verification_objective: objective, status: :active)
    applicant = create(:cbv_applicant)

    completed = create(:verification_request, :completed, cbv_applicant: applicant, verification_objective: objective, flow_definition: flow_definition)
    create(:verification_request, :expired, cbv_applicant: applicant, verification_objective: objective, flow_definition: flow_definition)
    create(:verification_step, verification_request: completed, step_key: "identity")

    metrics = described_class.new.dashboard

    expect(metrics[:completion_rate]).to eq(50.0)
    expect(metrics[:median_time_to_complete_seconds]).to be_a(Numeric)
  end
end
