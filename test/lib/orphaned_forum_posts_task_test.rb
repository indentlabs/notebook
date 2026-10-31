require 'test_helper'
require 'rake'

class OrphanedForumPostsTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('cleanup:orphaned_forum_posts')
    Rake::Task['cleanup:orphaned_forum_posts'].reenable

    author = users(:one)
    author.update_columns(created_at: 2.days.ago)
    messageboard = Thredded::Messageboard.create!(name: 'General')

    kept = Thredded::TopicForm.new(title: 'Kept', content: 'KEPT', user: author, messageboard: messageboard)
    gone = Thredded::TopicForm.new(title: 'Gone', content: 'GONE', user: author, messageboard: messageboard)
    assert kept.save
    assert gone.save
    @kept_post = kept.topic.posts.first
    @orphan = gone.topic.posts.first
    Thredded::Topic.where(id: gone.topic.id).delete_all
  end

  test "only reports orphaned posts by default" do
    assert_output(/Found 1 forum post without a topic/) do
      Rake::Task['cleanup:orphaned_forum_posts'].invoke
    end

    assert Thredded::Post.exists?(@orphan.id)
  end

  test "soft-deletes orphaned posts with APPLY=1" do
    ENV['APPLY'] = '1'
    capture_io { Rake::Task['cleanup:orphaned_forum_posts'].invoke }

    assert_not Thredded::Post.exists?(@orphan.id)
    assert Thredded::Post.with_deleted.exists?(@orphan.id)
    assert Thredded::Post.exists?(@kept_post.id)
  ensure
    ENV.delete('APPLY')
  end
end
