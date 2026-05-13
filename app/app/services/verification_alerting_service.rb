class VerificationAlertingService
  Alert = Struct.new(:type, :count, :threshold, keyword_init: true)

  def initialize(window: 1.hour, logger: Rails.logger)
    @window = window
    @logger = logger
  end

  def alerts
    [
      threshold_alert(:token_failures, VerificationEvent.where(event_type: "token_exchange_failed"), 5),
      threshold_alert(:upload_failures, VerificationEvent.where(event_type: "upload_failed"), 5),
      threshold_alert(:abandonment_spike, VerificationRequest.where(status: :expired), 10)
    ].compact
  end

  private

  def threshold_alert(type, scope, threshold)
    count = scope.where("created_at >= ?", @window.ago).count
    return nil if count < threshold

    @logger.warn("#{type} threshold exceeded", count:, threshold:, window: @window)
    Alert.new(type:, count:, threshold:)
  end
end
