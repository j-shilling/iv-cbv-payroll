require "rails_helper"

RSpec.describe Api::V1::VerificationRequestsController, type: :controller do
  let(:service_user) { create(:user, :with_access_token, is_service_account: true) }
  let(:token) { service_user.api_access_tokens.first.access_token }
  let(:cbv_applicant) { create(:cbv_applicant) }
  let(:objective) { create(:verification_objective, objective_key: "income") }

  before { request.headers["Authorization"] = "Bearer #{token}" }

  describe "POST #create" do
    context "when no active definition exists" do
      before { create(:flow_definition, verification_objective: objective, status: :draft) }

      it "returns unprocessable content" do
        post :create, params: { cbv_applicant_id: cbv_applicant.id, objective_key: "income", case_identifier: "CASE-1" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body).fetch("errors")).to include("No active definition for objective")
      end
    end
  end

  describe "POST #exchange_entry_token" do
    let!(:flow_definition) { create(:flow_definition, verification_objective: objective, status: :active) }
    let!(:verification_request) do
      create(:verification_request,
             cbv_applicant: cbv_applicant,
             verification_objective: objective,
             flow_definition: flow_definition,
             definition_snapshot: flow_definition.definition_payload,
             status: :created)
    end

    it "rejects unauthorized access" do
      request.headers["Authorization"] = nil
      post :issue_entry_token, params: { id: verification_request.id }
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects expired token" do
      token = VerificationRequestEntryTokenService.generate(verification_request)
      verification_request.update!(entry_token_expires_at: 1.minute.ago)
      post :exchange_entry_token, params: { token: token }
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows one-time token exchange" do
      post :issue_entry_token, params: { id: verification_request.id }
      token = JSON.parse(response.body).fetch("token")

      post :exchange_entry_token, params: { token: token }
      expect(response).to have_http_status(:ok)
      expect(verification_request.reload.status).to eq("in_progress")

      post :exchange_entry_token, params: { token: token }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
