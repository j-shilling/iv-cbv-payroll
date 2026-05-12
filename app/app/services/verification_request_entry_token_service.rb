class VerificationRequestEntryTokenService
  TTL = 15.minutes

  def self.generate(verification_request)
    payload = {
      verification_request_id: verification_request.id,
      nonce: SecureRandom.hex(16),
      exp: TTL.from_now.to_i
    }

    token = verifier.generate(payload)
    digest = Digest::SHA256.hexdigest(payload[:nonce])

    verification_request.update!(entry_token_digest: digest, entry_token_expires_at: Time.at(payload[:exp]), entry_token_used_at: nil)

    token
  end

  def self.exchange(token)
    payload = verifier.verify(token)
    verification_request = VerificationRequest.find(payload.fetch("verification_request_id"))
    return nil if Time.at(payload.fetch("exp")) < Time.current

    digest = Digest::SHA256.hexdigest(payload.fetch("nonce"))
    return nil unless ActiveSupport::SecurityUtils.secure_compare(verification_request.entry_token_digest.to_s, digest)
    return nil if verification_request.entry_token_used_at.present?
    return nil if verification_request.entry_token_expires_at.blank? || verification_request.entry_token_expires_at < Time.current

    verification_request.update!(entry_token_used_at: Time.current)

    verification_request
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound, KeyError
    nil
  end

  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base, serializer: JSON)
  end
end
