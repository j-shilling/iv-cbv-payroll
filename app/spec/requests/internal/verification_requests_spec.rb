require "rails_helper"

RSpec.describe "Internal::VerificationRequests", type: :request do
  it "renders worker review summary with responses and evidence" do
    objective = create(:verification_objective, objective_key: "student_enrollment_verification")
    definition = create(:flow_definition, :active, verification_objective: objective)
    request = create(:verification_request, verification_objective: objective, flow_definition: definition, definition_snapshot: definition.definition_payload)
    step = create(:verification_step, verification_request: request, step_key: "school_details", payload: { "school_name" => "Springfield University" })
    create(:verification_evidence, verification_request: request, verification_step: step, payload: { "filename" => "proof.pdf" })

    get "/internal/verification_requests/#{request.id}"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Worker review summary", "Springfield University", "proof.pdf")
  end
end
