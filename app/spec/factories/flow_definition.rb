FactoryBot.define do
  factory :flow_definition do
    verification_objective
    version { 1 }
    status { :draft }
    definition_payload { { "steps" => [ { "key" => "collect_paystub" } ] } }
  end
end
