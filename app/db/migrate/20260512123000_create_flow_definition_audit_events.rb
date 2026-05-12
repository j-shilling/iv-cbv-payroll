class CreateFlowDefinitionAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :flow_definition_audit_events do |t|
      t.references :flow_definition, null: true, foreign_key: true
      t.references :verification_objective, null: false, foreign_key: true
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end

    add_index :flow_definition_audit_events, %i[verification_objective_id created_at], name: "idx_flow_definition_audit_events_on_objective_created"
  end
end
