class AddBucketToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :s3_bucket, :string, default: 'basil-commissions'
  end
end
