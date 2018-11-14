class AddMoreIndicesToTables < ActiveRecord::Migration[5.2]
  def change
    add_index :users, [:id, :deleted_at]

    add_index :characters, [:id, :deleted_at]
    add_index :countries, [:id, :deleted_at]
    add_index :creatures, [:id, :deleted_at]
    add_index :deities, [:id, :deleted_at]
    add_index :floras, [:id, :deleted_at]
    add_index :governments, [:id, :deleted_at]
    add_index :groups, [:id, :deleted_at]
    add_index :items, [:id, :deleted_at]
    add_index :landmarks, [:id, :deleted_at]
    add_index :languages, [:id, :deleted_at]
    add_index :locations, [:id, :deleted_at]
    add_index :magics, [:id, :deleted_at]
    add_index :planets, [:id, :deleted_at]
    add_index :races, [:id, :deleted_at]
    add_index :religions, [:id, :deleted_at]
    add_index :scenes, [:id, :deleted_at]
    add_index :technologies, [:id, :deleted_at]
    add_index :towns, [:id, :deleted_at]
    add_index :universes, [:id, :deleted_at]

    # These indices fail with the message at the end of this file. They should be added somewhere else.
    # add_index :attribute_categories, [:entity_type, :name, :label, :user_id, :created_at], name: 'entity_type_name_label_user_id_created_at'
    # add_index :attribute_categories, [:deleted_at, :user_id, :entity_type, :hidden], name: 'entity_type_name_label_user_id_deleted_at'
    # add_index :attribute_categories, [:deleted_at, :user_id, :entity_type, :hidden, :created_at], name: 'entity_type_name_label_user_id_created_at_deleted_at'

    add_index :attribute_fields, [:attribute_category_id, :label, :old_column_source, :user_id, :field_type], name: 'attribute_fields_aci_label_ocs_ui_ft'
    add_index :attribute_fields, [:attribute_category_id, :label, :old_column_source, :field_type], name: 'attribute_fields_aci_label_ocs_ft'
    add_index :attribute_fields, [:deleted_at, :user_id, :attribute_category_id, :label, :hidden], name: 'attribute_fields_da_ui_aci_l_h'
    add_index :attribute_fields, [:attribute_category_id, :deleted_at]

    add_index :attributes, [:attribute_field_id, :deleted_at]
    add_index :attributes, [:attribute_field_id, :deleted_at, :entity_id, :entity_type], name: 'attributes_afi_deleted_at_entity_id_entity_type'
  end
end

# PG::ProgramLimitExceeded: ERROR:  index row size 4592 exceeds maximum 2712 for index "entity_type_name_label_user_id_created_at"
# HINT:  Values larger than 1/3 of a buffer page cannot be indexed.
# Consider a function index of an MD5 hash of the value, or use full text indexing.
# : CREATE  INDEX  "entity_type_name_label_user_id_created_at" ON "attribute_categories"  ("entity_type", "name", "label", "user_id", "created_at")
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:75:in `async_exec'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:75:in `block (2 levels) in execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/dependencies/interlock.rb:48:in `block in permit_concurrent_loads'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/concurrency/share_lock.rb:187:in `yield_shares'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/dependencies/interlock.rb:47:in `permit_concurrent_loads'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:74:in `block in execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:579:in `block (2 levels) in log'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:578:in `block in log'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/notifications/instrumenter.rb:23:in `instrument'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:569:in `log'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:73:in `execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/schema_statements.rb:466:in `add_index'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:871:in `block in method_missing'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:840:in `block in say_with_time'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:840:in `say_with_time'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:860:in `method_missing'
# /app/db/migrate/20181030051214_add_more_indices_to_tables.rb:25:in `change'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:814:in `exec_migration'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:798:in `block (2 levels) in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:797:in `block in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/connection_pool.rb:414:in `with_connection'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:796:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:977:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1292:in `block in execute_migration_in_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1343:in `block in ddl_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/database_statements.rb:254:in `block in transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/transaction.rb:230:in `block in within_new_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/transaction.rb:227:in `within_new_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/database_statements.rb:254:in `transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/transactions.rb:212:in `transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1343:in `ddl_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1291:in `execute_migration_in_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1263:in `block in migrate_without_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1262:in `each'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1262:in `migrate_without_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1210:in `block in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1363:in `with_advisory_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1210:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1036:in `up'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1011:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/tasks/database_tasks.rb:172:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/railties/databases.rake:60:in `block (2 levels) in <top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/rake-12.3.1/exe/rake:27:in `<top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:74:in `load'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:74:in `kernel_load'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:27:in `run'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:360:in `exec'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/invocation.rb:126:in `invoke_command'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor.rb:369:in `dispatch'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:20:in `dispatch'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/base.rb:444:in `start'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:10:in `start'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/exe/bundle:30:in `block in <top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/friendly_errors.rb:121:in `with_friendly_errors'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/exe/bundle:22:in `<top (required)>'
# /app/bin/bundle:3:in `load'
# /app/bin/bundle:3:in `<main>'
#
# Caused by:
# ActiveRecord::StatementInvalid: PG::ProgramLimitExceeded: ERROR:  index row size 4592 exceeds maximum 2712 for index "entity_type_name_label_user_id_created_at"
# HINT:  Values larger than 1/3 of a buffer page cannot be indexed.
# Consider a function index of an MD5 hash of the value, or use full text indexing.
# : CREATE  INDEX  "entity_type_name_label_user_id_created_at" ON "attribute_categories"  ("entity_type", "name", "label", "user_id", "created_at")
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:75:in `async_exec'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:75:in `block (2 levels) in execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/dependencies/interlock.rb:48:in `block in permit_concurrent_loads'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/concurrency/share_lock.rb:187:in `yield_shares'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/dependencies/interlock.rb:47:in `permit_concurrent_loads'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:74:in `block in execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:579:in `block (2 levels) in log'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:578:in `block in log'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/notifications/instrumenter.rb:23:in `instrument'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:569:in `log'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:73:in `execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/schema_statements.rb:466:in `add_index'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:871:in `block in method_missing'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:840:in `block in say_with_time'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:840:in `say_with_time'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:860:in `method_missing'
# /app/db/migrate/20181030051214_add_more_indices_to_tables.rb:25:in `change'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:814:in `exec_migration'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:798:in `block (2 levels) in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:797:in `block in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/connection_pool.rb:414:in `with_connection'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:796:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:977:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1292:in `block in execute_migration_in_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1343:in `block in ddl_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/database_statements.rb:254:in `block in transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/transaction.rb:230:in `block in within_new_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/transaction.rb:227:in `within_new_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/database_statements.rb:254:in `transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/transactions.rb:212:in `transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1343:in `ddl_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1291:in `execute_migration_in_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1263:in `block in migrate_without_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1262:in `each'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1262:in `migrate_without_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1210:in `block in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1363:in `with_advisory_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1210:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1036:in `up'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1011:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/tasks/database_tasks.rb:172:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/railties/databases.rake:60:in `block (2 levels) in <top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/rake-12.3.1/exe/rake:27:in `<top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:74:in `load'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:74:in `kernel_load'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:27:in `run'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:360:in `exec'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/invocation.rb:126:in `invoke_command'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor.rb:369:in `dispatch'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:20:in `dispatch'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/base.rb:444:in `start'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:10:in `start'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/exe/bundle:30:in `block in <top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/friendly_errors.rb:121:in `with_friendly_errors'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/exe/bundle:22:in `<top (required)>'
# /app/bin/bundle:3:in `load'
# /app/bin/bundle:3:in `<main>'
#
# Caused by:
# PG::ProgramLimitExceeded: ERROR:  index row size 4592 exceeds maximum 2712 for index "entity_type_name_label_user_id_created_at"
# HINT:  Values larger than 1/3 of a buffer page cannot be indexed.
# Consider a function index of an MD5 hash of the value, or use full text indexing.
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:75:in `async_exec'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:75:in `block (2 levels) in execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/dependencies/interlock.rb:48:in `block in permit_concurrent_loads'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/concurrency/share_lock.rb:187:in `yield_shares'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/dependencies/interlock.rb:47:in `permit_concurrent_loads'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:74:in `block in execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:579:in `block (2 levels) in log'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:578:in `block in log'
# /app/vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.0/lib/active_support/notifications/instrumenter.rb:23:in `instrument'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract_adapter.rb:569:in `log'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/database_statements.rb:73:in `execute'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/postgresql/schema_statements.rb:466:in `add_index'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:871:in `block in method_missing'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:840:in `block in say_with_time'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:840:in `say_with_time'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:860:in `method_missing'
# /app/db/migrate/20181030051214_add_more_indices_to_tables.rb:25:in `change'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:814:in `exec_migration'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:798:in `block (2 levels) in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:797:in `block in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/connection_pool.rb:414:in `with_connection'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:796:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:977:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1292:in `block in execute_migration_in_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1343:in `block in ddl_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/database_statements.rb:254:in `block in transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/transaction.rb:230:in `block in within_new_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/transaction.rb:227:in `within_new_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/connection_adapters/abstract/database_statements.rb:254:in `transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/transactions.rb:212:in `transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1343:in `ddl_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1291:in `execute_migration_in_transaction'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1263:in `block in migrate_without_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1262:in `each'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1262:in `migrate_without_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1210:in `block in migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1363:in `with_advisory_lock'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1210:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1036:in `up'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/migration.rb:1011:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/tasks/database_tasks.rb:172:in `migrate'
# /app/vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.0/lib/active_record/railties/databases.rake:60:in `block (2 levels) in <top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/rake-12.3.1/exe/rake:27:in `<top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:74:in `load'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:74:in `kernel_load'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli/exec.rb:27:in `run'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:360:in `exec'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/invocation.rb:126:in `invoke_command'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor.rb:369:in `dispatch'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:20:in `dispatch'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/vendor/thor/lib/thor/base.rb:444:in `start'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/cli.rb:10:in `start'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/exe/bundle:30:in `block in <top (required)>'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/lib/bundler/friendly_errors.rb:121:in `with_friendly_errors'
# /app/vendor/bundle/ruby/2.5.0/gems/bundler-1.15.2/exe/bundle:22:in `<top (required)>'
# /app/bin/bundle:3:in `load'
# /app/bin/bundle:3:in `<main>'
# Tasks: TOP => db:migrate
# (See full trace by running task with --trace)
