class CreateVerificationWorkflowTables < ActiveRecord::Migration[8.1]
  def change
    create_table :verification_objectives do |t|
      t.string :objective_key, null: false
      t.integer :version, null: false
      t.string :name, null: false
      t.text :description
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :verification_objectives, %i[objective_key version], unique: true
    add_index :verification_objectives, :objective_key

    create_table :flow_definitions do |t|
      t.references :verification_objective, null: false, foreign_key: true
      t.integer :version, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :definition_payload, null: false, default: {}
      t.datetime :published_at

      t.timestamps
    end

    add_index :flow_definitions, %i[verification_objective_id version], unique: true, name: "idx_flow_definitions_on_objective_and_version"
    add_index :flow_definitions, %i[verification_objective_id status], name: "idx_flow_definitions_on_objective_and_status"

    create_table :verification_requests do |t|
      t.string :case_identifier, null: false
      t.references :cbv_applicant, null: false, foreign_key: true
      t.references :verification_objective, null: false, foreign_key: true
      t.references :flow_definition, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.references :assigned_user, null: true, foreign_key: { to_table: :users }
      t.datetime :requested_at, null: false
      t.datetime :completed_at
      t.jsonb :definition_snapshot, null: false, default: {}

      t.timestamps
    end

    add_index :verification_requests, %i[case_identifier status], name: "idx_verification_requests_caseworker_queue"
    add_index :verification_requests, %i[verification_objective_id requested_at], name: "idx_verification_requests_objective_history"

    create_table :verification_steps do |t|
      t.references :verification_request, null: false, foreign_key: true
      t.string :step_key, null: false
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end

    add_index :verification_steps, %i[verification_request_id created_at], name: "idx_verification_steps_request_timeline"
    add_index :verification_steps, %i[verification_request_id step_key], unique: true, name: "idx_verification_steps_request_step_key"

    create_table :verification_evidence do |t|
      t.references :verification_request, null: false, foreign_key: true
      t.references :verification_step, null: true, foreign_key: true
      t.string :evidence_type, null: false
      t.string :source_system
      t.string :external_reference
      t.jsonb :payload, null: false, default: {}
      t.datetime :collected_at, null: false

      t.timestamps
    end

    add_index :verification_evidence, %i[verification_request_id collected_at], name: "idx_verification_evidence_request_timeline"

    create_table :verification_events do |t|
      t.references :verification_request, null: false, foreign_key: true
      t.references :verification_step, null: true, foreign_key: true
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :verification_events, %i[verification_request_id occurred_at], name: "idx_verification_events_request_timeline"
  end
end
