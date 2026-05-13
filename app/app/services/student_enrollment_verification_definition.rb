class StudentEnrollmentVerificationDefinition
  OBJECTIVE_KEY = "student_enrollment_verification".freeze
  FEATURE_FLAG = "FEATURE_STUDENT_ENROLLMENT_VERIFICATION".freeze

  def self.enabled?
    ENV.fetch(FEATURE_FLAG, "false") == "true"
  end

  def self.payload
    {
      "metadata" => {
        "name" => "Student enrollment verification",
        "objective_key" => OBJECTIVE_KEY
      },
      "steps" => [
        {
          "key" => "attestation",
          "fields" => [
            { "name" => "attest_information_is_true", "required" => true }
          ]
        },
        {
          "key" => "school_details",
          "fields" => [
            { "name" => "school_name", "required" => true },
            { "name" => "student_id", "required" => false },
            { "name" => "term_start_date", "required" => true }
          ]
        },
        {
          "key" => "evidence_upload",
          "fields" => [
            { "name" => "document_uploaded", "required" => true }
          ]
        }
      ],
      "branching" => [],
      "evidence" => {
        "required" => ["enrollment_document"]
      },
      "completion" => {
        "strategy" => "all_required_steps"
      },
      "security" => {
        "encryption_required" => true
      }
    }
  end
end
