require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let!(:country) { FactoryBot.create(:country) }
  render_views
  describe "Admin::Users" do
    before(:each) do
      @admin = FactoryBot.create(:admin_user)
      sign_in @admin
    end  
  

# Create
describe "Post#new" do
  let(:wrong_params) do 
    {
      full_name: 'John carter', 
      full_phone_number:  "+96650#{Faker::Number.unique.number(digits: 7).to_s}",
      government_id: "9#{rand.to_s[2..10]}",
      app_language_id: 2,
      email: Faker::Internet.email,
      activated: true 
    }
  end
  it 'should not create account' do
    post :create, params: wrong_params
    expect(response.code).to eq('200')
  end

  let(:params) do {
    account: {
      full_name: 'John carter', 
      full_phone_number:  "+96650#{Faker::Number.unique.number(digits: 7).to_s}",
      government_id: "9#{rand.to_s[2..10]}",
      app_language_id: 2,
      email: Faker::Internet.email,
      activated: true }
    }
  end

  # it 'should create account' do
  #   post :create, params: params
  #   expect(response.message).to eq 'OK'
  #   expect(response).to redirect_to(admin_user_path(AccountBlock::Account.last.id))
  # end

  it 'should not create account' do
    post :create, params: { }, as: :json
    expect(response.code).to eq('422')
    expect(JSON.parse(response.body)['errors']['government_id'][0]).to eq("can't be blank")
    expect(JSON.parse(response.body)['errors']['government_id'][1]).to eq("government id must be 10 digit")
  end
end

# Index
describe "Get#index" do
  let!(:accounts) { create_list(:account, 3)}
  it 'should show all account' do
    get :index
    expect(response.code).to eq('200')
    expect(response.body).to include(accounts.first.full_phone_number)
    expect(response.body).to include('View')
    expect(response.body).to include('Edit')
  end
end

# Show
describe "Get#show" do
  let(:account) { create(:account)}
  let(:loan) { FactoryBot.create(:approved_loan , account_id: account.id) }
  let(:installment) { FactoryBot.create(:installment , approved_loan_id: loan.id) }
  let(:params) do {
        id: account.id, 
        loan: loan,
        installment: installment
         }
  end

  it 'should show the account' do
    account.first_name = 'HUZAYM'
    account.personal_info = {"firstNameT"=>"HUZAYM", "firstName"=>"هزيم", "grandFatherName"=>"حامد", "grandFatherNameT"=>"HAMED", "maritalStatusDescAr"=>"زوجة واحدة"}
    account.personal_id_info = {"idExpirationDate"=>"2023-01-10T00:00:00", "idIssueDate"=>"2021-01-10T00:00:00", "idIssuePlaceDescAR"=>"أحوال مقر الوكالة بالرياض     "}
    account.address_info = {"ObjLatLng"=>"39.19311354 21.62226782", "BuildingNumber"=>"8478", "Street"=>"عبدالجليل ياسين", "District"=>"حي المروة", "City"=>"جدة", "PostCode"=>"23542", "AdditionalNumber"=>"3142", "IsPrimaryAddress"=>"true", "UnitNumber"=>nil}
    account.save
    get :show, params: params
    expect(response.code).to eq('200')
    expect(response.body).to include(account.full_name)
    expect(response.body).to include(account.full_phone_number)
    expect(response.body).to include('Edit User')

     expect(response.body).to include(loan.id.to_s)
        expect(response.body).to include(loan.id.to_s)
       expect(response.body).to include(loan.status)
       # expect(response.body).to include(loan.rent.to_s)

       loan.installments.each do |installment|
         expect(response.body).to include(installment.id.to_s)
         expect(response.body).to include(installment.status)
         expect(response.body).to include(installment.rent.to_s)
       end
    expect(response.body).to include('Building Number')
  end
end

describe "PUT #delete_user" do
  let(:user) { create(:account) }
  it "updates the status of the user to deleted" do
    put :deactivate_user, params: { id: user.id }
    user.reload
    expect(user.status).to eq("deleted")
  end

  it "redirects to the index page with a notice message" do
    put :deactivate_user, params: { id: user.id }
    expect(response).to redirect_to(admin_users_path)     
  end
end

describe "PUT #deactivate_user" do
  let(:user) { create(:account) }
  it "redirects to the index page with a notice message" do
    put :deactivate_user, params: { id: user.id }
    expect(response).to redirect_to(admin_users_path)     
  end

  it "show error when unpaid installment present" do
    approved_loan.destroy
    allow_any_instance_of(AccountBlock::Account).to receive(:update_columns).and_return(false)
    put :deactivate_user, params: { id: user.id }
    expect(flash['alert']).to eq('Failed to delete the account.')
  end

  let!(:approved_loan) { create(:approved_loan, account_id: user.id) }
  it "show error when unpaid installment present" do
    put :deactivate_user, params: { id: user.id }
    expect(flash['alert']).to eq('Cannot delete account. There are unpaid installments.')
  end
end
  end
end