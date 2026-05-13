require "rails_helper"

RSpec.describe "Internal verification request branch debug", type: :request do
  it "returns branch outcome and can persist the decision" do
    allow(Rails.application.config).to receive(:is_internal_environment).and_return(true)
    request_record = create(:verification_request, definition_snapshot: {
      "branching" => [
        { "key" => "missing_doc", "priority" => 1, "branch" => "attestation_path", "conditions" => [] }
      ],
      "evidence" => {
        "required" => ["enrollment_document"],
        "conditional" => [
          { "if_missing" => "enrollment_document", "then_require" => ["attestation_statement"] }
        ]
      },
      "completion" => { "fallback_branch" => "manual_review" }
    })

    get branch_debug_internal_verification_request_path(request_record, persist: true)

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.dig("branch", "branch_key")).to eq("attestation_path")
    expect(json.dig("evidence", "required")).to include("attestation_statement")
    expect(request_record.verification_events.where(event_type: "branch_decision_recorded")).to exist
  end
end
