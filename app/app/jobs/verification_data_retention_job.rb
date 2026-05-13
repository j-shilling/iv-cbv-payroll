class VerificationDataRetentionJob < ApplicationJob
  queue_as :default

  RETAIN_COMPLETED_FOR = 180.days

  def perform
    DataRetentionService.new.redact_all!

    VerificationRequest
      .completed
      .where("completed_at < ?", RETAIN_COMPLETED_FOR.ago)
      .find_each do |request|
        request.verification_steps.delete_all
        request.verification_evidence.delete_all
        request.verification_events.delete_all
        request.destroy!
      end
  end
end
