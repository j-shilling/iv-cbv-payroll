FactoryBot.define do
  factory :verification_objective do
    sequence(:objective_key) { |n| "income_verification_#{n}" }
    version { 1 }
    name { "Income verification" }
    description { "Verify applicant income" }
    metadata { {} }
  end
end
