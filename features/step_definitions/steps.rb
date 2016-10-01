When 'I sign up' do
  @user = build(:user)

  visit new_user_registration_path
  fill_in 'user_name', with: 'User Name'
  fill_in 'user_email', with: @user.email
  fill_in 'user_password', with: 'password'
  fill_in 'user_password_confirmation', with: 'password'
  click_button 'Sign up'

  @user = User.where(email: @user.email).first
end

Given 'I have an account' do
  step('I sign up')
end

When 'I log in' do
  step('I log out')
  visit new_user_session_path
  fill_in 'user_email', with: @user.email
  fill_in 'user_password', with: 'password'
  click_button 'Log in'
end

When 'I log out' do
  visit destroy_user_session_path
end

Then 'I should see my dashboard' do
  expect(current_path).to eq(dashboard_path)
end

When /^I create a (character|location|item|universe)$/ do |model|
  visit new_polymorphic_path(model)
  fill_in "#{model}_name", with: 'My new content'
  click_on "Create #{model.titlecase}"
end

Then /^that (character|location|item|universe) should be saved$/ do |model|
  expect(@user.send(model.pluralize).length).to eq(1)
end

Given /^I have created a (character|location|item|universe)$/ do |model|
  @model = create(model.to_sym, user: @user)
end

When /^I change my (character|location|item|universe)\'s name$/ do |model|
  visit polymorphic_path(@model)
  click_on "Edit this #{model}"
  fill_in "#{model}_name", with: 'My changed name'
  click_on "Update #{model.titlecase}"
  @model.reload
end

Then /^that new name should be saved$/ do
  expect(@model.name).to eq('My changed name')
end
