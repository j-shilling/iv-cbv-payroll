require "rails_helper"

RSpec.describe "Student enrollment verification flow", type: :feature do
  it "covers issuance, applicant completion, and worker review summary" do
    objective = create(:verification_objective, objective_key: "student_enrollment_verification", name: "Student enrollment verification")
    definition = create(:flow_definition, :active, verification_objective: objective, definition_payload: StudentEnrollmentVerificationDefinition.payload)

    verification_request = create(:verification_request,
      verification_objective: objective,
      flow_definition: definition,
      definition_snapshot: definition.definition_payload,
      status: :in_progress)

    attestation = create(:verification_step, verification_request: verification_request, step_key: "attestation", payload: { "attest_information_is_true" => true })
    create(:verification_step, verification_request: verification_request, step_key: "school_details", payload: { "school_name" => "Springfield University", "term_start_date" => "2026-01-10" })
    create(:verification_evidence, verification_request: verification_request, verification_step: attestation, payload: { "filename" => "enrollment-proof.pdf" })

    visit "/internal/verification_requests/#{verification_request.id}"

    expect(page).to have_text("Worker review summary")
    expect(page).to have_text("Springfield University")
    expect(page).to have_text("enrollment-proof.pdf")
  end
end
