require "rails_helper"

RSpec.describe FlowDefinitionValidator do
  subject(:errors) { described_class.new.validate(payload) }

  let(:payload) do
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

  it "accepts a valid payload" do
    expect(errors).to be_empty
  end

  it "returns path-specific errors for invalid nested fields" do
    payload["steps"][0]["fields"][0]["required"] = "yes"

    expect(errors.map(&:path)).to include("steps[0].fields[0].required")
  end

  it "returns multiple section errors" do
    payload["metadata"] = "bad"
    payload["completion"] = {}

    expect(errors.map(&:path)).to include("metadata", "completion.strategy")
  end
end
