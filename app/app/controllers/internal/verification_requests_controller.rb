module Internal
  class VerificationRequestsController < ApplicationController
    before_action :ensure_internal_environment

    def show
      @verification_request = VerificationRequest
        .includes(:verification_objective, :verification_steps, :verification_evidence)
        .find(params[:id])
    end

    private

    def ensure_internal_environment
      raise ActionController::RoutingError, "Not Found" unless Rails.application.config.is_internal_environment
    end
  end
end
