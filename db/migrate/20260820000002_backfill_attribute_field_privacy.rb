class BackfillAttributeFieldPrivacy < ActiveRecord::Migration[6.1]
  def up
    # The privacy column has existed (defaulting to 'public') but was never enforced,
    # so normalize any stray values before we start reading it.
    execute <<-SQL
      UPDATE attribute_fields
      SET privacy = 'public'
      WHERE privacy IS NULL OR privacy NOT IN ('public', 'contributors', 'private')
    SQL

    # Private Notes fields have always been hidden from everyone but the page owner
    # (previously hardcoded against old_column_source in the serializers), so express
    # that behavior through the privacy column.
    execute <<-SQL
      UPDATE attribute_fields
      SET privacy = 'private'
      WHERE old_column_source = 'private_notes'
    SQL
  end

  def down
    # No-op: the previous state was an unenforced column, so there is nothing to restore
  end
end
