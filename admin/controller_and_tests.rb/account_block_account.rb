ActiveAdmin.register AccountBlock::Account, as: "accounts" do
    permit_params :email, :password, :profile_picture, category_ids: [], subcategory_ids: []
  
    index do
      selectable_column
      id_column
      column :email
      column :status
      actions
    end
  
    filter :email
    filter :status
  
    show do
      attributes_table do
        row :id
        row :first_name
        row :email
        row :full_phone_number
        row :type
        row :country_code
        row :activated
        row :status
        row :profile_picture do |account|
          image_tag url_for(account.profile_picture) if account.profile_picture.attached?
        end
      end
    end
  
    form do |f|
      f.inputs 'Account Details' do
        f.input :email
        f.input :password
        f.input :profile_picture, as: :file
      end
      f.actions
    end
  
    member_action :add_categories, method: :get do
      @account = resource
      @categories = BxBlockCategories::Category.all
  
      render "admin/account_block/accounts/add_categories"
    end
  
    member_action :assign_categories, method: :post do
      @account = resource
      category_ids = params[:account][:category_ids]
      @account.categories = BxBlockCategories::Category.where(id: category_ids)
      redirect_to admin_account_path(@account), notice: "Categories assigned successfully"
    end
  
    member_action :add_subcategories, method: :get do
      @account = resource
      @categories = @account.categories
      render "admin/account_block/accounts/add_subcategories"
    end
  
    member_action :assign_subcategories, method: :post do
      @account = resource
      subcategory_ids = params[:account][:subcategory_ids]
      @account.subcategories = BxBlockCategories::SubCategory.where(id: subcategory_ids)
      redirect_to admin_account_path(@account), notice: "Subcategories assigned successfully"
    end
  
    action_item :add_categories, only: :show do
      link_to "Add Categories", add_categories_admin_account_path(resource)
    end
  
    action_item :add_subcategories, only: :show do
      link_to "Add Subcategories", add_subcategories_admin_account_path(resource)
    end
  end

  ================================================================================================================



  # spec/admin/accounts_spec.rb

require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  render_views
  before(:each) do
    @admin = FactoryBot.create(:admin_user)
    sign_in @admin
  end

  describe 'Index Page' do
    let!(:accounts) { create_list(:email_account, 3) }

    it 'displays a list of accounts' do
      sleep 10
      get :index
      expect(response).to have_http_status(200)
      expect(response.body).to include(accounts.first.email)
      expect(response.body).to include('View')
      expect(response.body).to include('Edit')
    end
  end

  describe 'Show Page' do
    it 'displays account details' do
      account = AccountBlock::Account.create(email: "akshay@gmail.com", password: "Akshay@420", activated: true)
      get :show, params: { id: account.id }
      expect(response.code).to eq('200')
    end
  end

  describe 'Edit Page' do
    it 'allows editing account details' do
      account = create(:email_account)

      get :edit, params: { id: account.id }
      expect(response.code).to eq('200')
    end
  end

  describe 'Add Categories' do
    it 'allows adding categories to an account' do
      account = create(:email_account)
      categories = FactoryBot.create_list(:category, 3)
      get :add_categories, params: { id: account.id }
      expect(response.code).to eq('200')
    end
  end

  describe 'Add Subcategories' do
    it 'allows adding subcategories to an account' do
      account = create(:email_account)
      categories = FactoryBot.create_list(:subcategory, 3)
      get :add_subcategories, params: { id: account.id }
      expect(response.code).to eq('200')
    end
  end

  describe 'Assign Categories' do
    it 'allows assigning categories to an account' do
      account = create(:email_account)
      categories = FactoryBot.create_list(:category, 3)
  
      post :assign_categories, params: { id: account.id, account: { category_ids: categories.pluck(:id) } }
      
      expect(response).to redirect_to(admin_account_path(account))
      expect(flash[:notice]).to eq('Categories assigned successfully')
      account.reload
      expect(account.categories).to match_array(categories)
    end
  end
  
  describe 'Assign Subcategories' do
    it 'allows assigning subcategories to an account' do
      account = create(:email_account)
      subcategories = FactoryBot.create_list(:subcategory, 3)
  
      post :assign_subcategories, params: { id: account.id, account: { subcategory_ids: subcategories.pluck(:id) } }
      
      expect(response).to redirect_to(admin_account_path(account))
      expect(flash[:notice]).to eq('Subcategories assigned successfully')
      account.reload
      expect(account.subcategories).to match_array(subcategories)
    end
  end
  
end

  