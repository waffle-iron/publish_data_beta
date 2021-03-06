require 'rails_helper'

describe "managing datasets" do
  before(:each) do
    o = Organisation.new
    o.name = 'land-registry'
    o.title = 'Land Registry'
    o.save!()

    User.create!(email:'test@localhost',
                 primary_organisation: o,
                 password: 'password',
                 password_confirmation: 'password')

    price_paid_dataset = Dataset.create!(
      name: 'price paid data',
      title: 'Price Paid data for all London Boroughs',
      summary: 'Price Paid Data tracks the residential property sales in England and Wales that are lodged with HM Land Registry for registration. ',
      organisation: o
    )

    searchable = Dataset.create!(
      name: 'searchable',
      title: 'Find data here',
      summary: 'A fake dataset for search ',
      organisation: o
    )

    visit '/'
    click_link 'Sign in'
    fill_in('user_email', with: 'test@localhost')
    fill_in('Password', with: 'password')
    click_button 'Sign in'
  end

  it "after login" do
    expect(page).to have_current_path '/tasks'

    # Don't expect any tables as creator_id not set on dataset
    click_link 'Manage datasets'
    expect(page).to have_selector(%(table), count: 0)

    # Expect to see the table with datasets in it.
    click_link 'Land Registry datasets'
    expect(page).to have_selector(%(table), count: 1)
  end

  it "can do a search" do
    click_link 'Manage datasets'
    click_link 'Land Registry datasets'

    # 4 TH includes 3 from header row
    expect(page).to have_selector(%(th), count: 5)
    fill_in('q', with: "find")
    click_button 'Search'

    # We expect to only have a single result now (plus the 3 header th)
    expect(page).to have_selector(%(th), count: 4)

    fill_in('q', with: "cats")
    click_button 'Search'
    # No results, no table.
    expect(page).to have_selector(%(th), count: 0)
  end

end
