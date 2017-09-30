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

Given 'I am logged-in' do
  step('I sign up')
end

When 'I log out' do
  visit destroy_user_session_path
end

When(/^I view the dashboard/) do
  visit dashboard_path
end

Then 'I should see my dashboard' do
  expect(current_path).to eq(dashboard_path)
end

When(/^I create a (character|location|item|universe)$/) do |model|
  visit new_polymorphic_path(model)
  fill_in "#{model}_name", with: 'My new content'
  click_on "Create"
  @model = model.classify.constantize.where(name: 'My new content', user: @user).first
end

Then(/^that (character|location|item|universe) should be saved$/) do |model|
  expect(@user.send(model.pluralize).length).to eq(1)
end

Given(/^I have created a (character|location|item|universe)$/) do |model|
  @model = create(model.to_sym, user: @user)
end

When(/^I change my (character|location|item|universe)\'s name$/) do |model|
  visit polymorphic_path(@model)
  click_on 'edit'
  fill_in "#{model}_name", with: 'My changed name'
  click_on 'save'
  @model.reload
end

When(/^I view that (character|location|item|universe)$/) do |_model|
  visit polymorphic_path(@model)
end

Then(/^that new name should be saved$/) do
  expect(@model.name).to eq('My changed name')
end

When 'I answer the Serendipitous question' do
  @modified_field_name = find(:css, '.content-question-input')[:id].split('_', 2)[1]
  @model[@modified_field_name] = 'Previous Value'
  @model.save
  @previous_field_value = @model[@modified_field_name]

  find(:css, '.content-question-input').set('Content Question Answer')
  find('.content-question-submit').click
end

Then 'that new field should be saved' do
  @model.reload
  expect(@model[@modified_field_name]).to eq('Content Question Answer')
end
