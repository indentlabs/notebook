When 'I am logged-in' do
  @user = create(:user)

  visit new_user_session_path
  fill_in 'user_email', with: @user.email
  fill_in 'user_password', with: @user.password
  click_button 'Log in'
end

When 'I create a character' do
  visit new_character_path
  fill_in 'character_name', with: 'My new character'
  click_on 'Create Character'
end

Then 'that character should be saved' do
  expect(@user.characters.length).to eq(1)
end

Given 'I have created a character' do
  @character = create(:character, user: @user)
end

When 'I change my character\'s name' do
  visit character_path(@character)
  click_on 'Edit this character'
  fill_in 'character_name', with: 'My character\'s changed name'
  click_on 'Update Character'
end

Then 'that new name should be saved' do
  expect(@user.characters.first.name).to eq('My character\'s changed name')
end
