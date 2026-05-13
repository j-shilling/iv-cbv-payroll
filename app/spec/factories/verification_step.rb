FactoryBot.define do
  factory :verification_step do
    verification_request
    sequence(:step_key) { |n| "step_#{n}" }
    payload { { "response" => "value" } }
    status { :completed }
  end
end
