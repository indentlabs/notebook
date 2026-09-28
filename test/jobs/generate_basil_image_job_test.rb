require "test_helper"
require "webmock/minitest"

# New Basil images must be stored so ActiveStorage can build variants from
# them: base64 MD5 checksum, image/png content type, known pixel size.
class GenerateBasilImageJobTest < ActiveJob::TestCase
  setup do
    @png = File.binread(Rails.root.join("test/fixtures/files/gallery_test.png"))
    @env = ENV.to_h.slice("BASIL_ENDPOINT", "BASIL_API_KEY", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY")
    ENV.update("BASIL_ENDPOINT" => "https://basil.test", "BASIL_API_KEY" => "k",
               "AWS_ACCESS_KEY_ID" => "id", "AWS_SECRET_ACCESS_KEY" => "secret")
    Aws.config[:s3] = { stub_responses: {
      put_object: { etag: %("#{Digest::MD5.hexdigest(@png)}") },
      get_object: { body: @png, content_type: "binary/octet-stream" }
    } }
    stub_request(:post, "https://basil.test/v1/image/generations")
      .to_return(status: 200, body: { image: Base64.strict_encode64(@png) }.to_json)

    @commission = BasilCommission.create!(user: users(:one), entity: characters(:one), prompt: "a hero", job_id: "job-abc")
  end

  teardown do
    Aws.config.delete(:s3)
    %w(BASIL_ENDPOINT BASIL_API_KEY AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY).each { |k| ENV[k] = @env[k] }
  end

  test "stores a blob ActiveStorage can build variants from" do
    GenerateBasilImageJob.perform_now(@commission.id)

    @commission.reload
    blob = @commission.image.blob
    assert_equal Digest::MD5.base64digest(@png), blob.checksum
    assert_equal "image/png", blob.content_type
    assert_equal "amazon_basil", blob.service_name
    assert_equal [64, 40], [@commission.width, @commission.height]
    assert_equal({ "identified" => true, "width" => 64, "height" => 40, "analyzed" => true }, blob.metadata)
    assert @commission.completed_at.present?
  end

  test "attach_stored_png! (used by complete_commission) derives everything from the image bytes" do
    @commission.attach_stored_png!("job-abc.png")

    blob = @commission.reload.image.blob
    assert_equal Digest::MD5.base64digest(@png), blob.checksum
    assert_equal "image/png", blob.content_type, "not S3's binary/octet-stream"
    assert_equal [64, 40], [@commission.width, @commission.height]
  end
end
