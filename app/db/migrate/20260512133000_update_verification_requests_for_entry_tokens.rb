class UpdateVerificationRequestsForEntryTokens < ActiveRecord::Migration[8.1]
  def change
    add_column :verification_requests, :due_date, :date
    add_column :verification_requests, :reminder_cadence, :string
    add_column :verification_requests, :note, :text
    add_column :verification_requests, :entry_token_digest, :string
    add_column :verification_requests, :entry_token_expires_at, :datetime
    add_column :verification_requests, :entry_token_used_at, :datetime
  end
end
