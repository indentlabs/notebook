# This is a version of EndOfDayAnalyticsJob that is meant to only ever be run in a console. There's
# no rake task to automatically use this. Pass a date string in as the arg.
class BackfilledEndOfDayAnalyticsJob < ApplicationJob
  queue_as :cache

  def perform(*args)
    report_date = args.shift.to_date
    timespan    = report_date.beginning_of_day..report_date.end_of_day

    report = EndOfDayAnalyticsReport.find_or_initialize_by(day: report_date)

    # Growth
    report.user_signups                   = User.where(created_at: timespan).count

    # Billing stuff
    report.new_monthly_subscriptions      = Subscription.where(start_date:  timespan, billing_plan_id: 4).count
    report.ended_monthly_subscriptions    = Subscription.where(end_date:    timespan, billing_plan_id: 4).count
    report.new_trimonthly_subscriptions   = Subscription.where(start_date:  timespan, billing_plan_id: 5).count
    report.ended_trimonthly_subscriptions = Subscription.where(end_date:    timespan, billing_plan_id: 5).count
    report.new_annual_subscriptions       = Subscription.where(start_date:  timespan, billing_plan_id: 6).count
    report.ended_annual_subscriptions     = Subscription.where(end_date:    timespan, billing_plan_id: 6).count
    report.paid_paypal_invoices           = PaypalInvoice.where(updated_at: timespan, status: "COMPLETED").count

    # Worldbuilding pages
    Rails.application.config.content_types[:all].each do |content_type|
      report.assign_attributes("#{content_type.name.downcase.pluralize}_created": content_type.where(created_at: timespan).count)
    end

    # Documents
    report.documents_created         = Document.where(created_at: timespan).count
    report.documents_edited          = Document.where(updated_at: timespan).count
    report.document_analyses_created = DocumentAnalysis.where(created_at: timespan).count

    # Timelines
    report.timelines_created = Timeline.where(created_at: timespan).count

    # Social
    report.stream_shares_created = ContentPageShare.where(created_at: timespan).count
    report.stream_comments       = ShareComment.where(created_at: timespan).count

    # Collections
    report.collections_created            = PageCollection.where(created_at: timespan).count
    report.collection_submissions_created = PageCollectionSubmission.where(created_at: timespan).count

    # Discussions
    report.thredded_threads_created          = Thredded::Topic.where(created_at: timespan).count
    report.thredded_replies_created          = Thredded::Post.where(created_at: timespan).count
    report.thredded_private_messages_created = Thredded::PrivateTopic.where(created_at: timespan).count
    report.thredded_private_replies_created  = Thredded::PrivatePost.where(created_at: timespan).count
    
    # Finish up :)
    report.save!
  end
end
