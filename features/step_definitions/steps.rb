When 'I am logged-in' do
  @user = create(:user)

  visit new_user_session_path
  fill_in 'user_email', with: @user.email
  fill_in 'user_password', with: @user.password
  click_button 'Log in'
end

When /^I create a (character|location|item)$/ do |model|
  visit new_polymorphic_path(model)
  fill_in "#{model}_name", with: 'My new content'
  click_on "Create #{model.titlecase}"
end

Then /^that (character|location|item) should be saved$/ do |model|
  expect(@user.send(model.pluralize).length).to eq(1)
end

Given /^I have created a (character|location|item)$/ do |model|
  @model = create(model.to_sym, user: @user)
end

When /^I change my (character|location|item)\'s name$/ do |model|
  visit polymorphic_path(@model)
  click_on "Edit this #{model}"
  fill_in "#{model}_name", with: 'My changed name'
  click_on "Update #{model.titlecase}"
  @model.reload
end

Then /^that new name should be saved$/ do
  expect(@model.name).to eq('My changed name')
end
