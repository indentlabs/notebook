require 'active_support/concern'

module HasPrivacyTest
  extend ActiveSupport::Concern

  included do
    test 'responds to public_content' do
        assert_respond_to(@object, :public_content?)
    end

    test 'responds to private_content' do
        assert_respond_to(@object, :private_content?)
    end

    test 'object is public when privacy field contains "public"' do
        @object.universe.privacy = 'private'
        @object.privacy = 'public'

        assert @object.public_content?
        refute @object.private_content?
    end

    test 'object is private when privacy field contains "private"' do
        @object.universe.privacy = 'private'
        @object.privacy = 'private'

        assert @object.private_content?
        refute @object.public_content?
    end

    test 'object is private when privacy field is empty' do
        @object.universe.privacy = 'private'
        @object.privacy = ''

        assert @object.private_content?
        refute @object.public_content?
    end

    test 'object is public when universe is public' do
        @object.universe.privacy = 'public'
        @object.privacy = 'private'

        assert @object.public_content?
        refute @object.private_content?
    end
  end
end
