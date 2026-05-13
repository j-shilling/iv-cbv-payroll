require "rails_helper"

RSpec.describe StudentEnrollmentVerificationDefinition do
  describe ".payload" do
    it "includes attestation, school details, and evidence upload steps" do
      step_keys = described_class.payload.fetch("steps").map { |step| step.fetch("key") }

      expect(step_keys).to eq(%w[attestation school_details evidence_upload])
    end
  end
end
