class VerificationDefinitionMetrics
  def initialize(scope: VerificationRequest.all)
    @scope = scope
  end

  def dashboard
    total = @scope.count
    completed_scope = @scope.completed
    abandoned_scope = @scope.where(status: :expired)

    {
      completion_rate: percentage(completed_scope.count, total),
      abandonment_step: most_common_abandonment_step,
      median_time_to_complete_seconds: median_completion_time(completed_scope)
    }
  end

  private

  def most_common_abandonment_step
    VerificationStep
      .where(verification_request_id: @scope.where(status: :expired).select(:id))
      .group(:step_key)
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(1)
      .pluck(:step_key)
      .first
  end

  def median_completion_time(completed_scope)
    seconds = completed_scope.where.not(completed_at: nil).pluck(Arel.sql("EXTRACT(EPOCH FROM completed_at - requested_at)"))
    return nil if seconds.empty?

    sorted = seconds.sort
    mid = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) / 2.0)
  end

  def percentage(part, total)
    return 0.0 if total.zero?

    ((part.to_f / total) * 100).round(2)
  end
end
