require 'rails_helper'
require 'support/privacy_example'
require 'support/public_scope_example'
require 'support/name_validation_example'

RSpec.describe Universe, type: :model do
  it_behaves_like 'content with privacy'
  it_behaves_like 'content that validates presence of name'
end
