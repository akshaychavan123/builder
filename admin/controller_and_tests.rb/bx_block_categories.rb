ActiveAdmin.register BxBlockCategories::Category, as: "categories" do
    permit_params :name, :identifier, :other_attributes
  
    index do
      selectable_column
      id_column
      column :name
      column :identifier
      actions
    end
  
    filter :name
    filter :identifier
  
    form do |f|
      f.inputs 'Category Details' do
        f.input :name
        f.input :identifier
      end
      f.actions
    end
  end
  =====================================================================================================

  require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  render_views
  let(:admin) { FactoryBot.create(:admin_user) }

  before do
    sign_in admin
  end

  describe 'Index Page' do
    let(:categories) { create_list(:category, 3) }

    it 'displays a list of categories' do
      puts categories.first.name
      get :index
      expect(response.code).to eq('200')
      expect(response.body).to include(categories.first.name)
      expect(response.body).to include('View')
      expect(response.body).to include('Edit')
    end
  end

  describe 'Show Page' do
    it 'displays category details' do
      category = BxBlockCategories::Category.create(name: "Category Name")
      get :show, params: { id: category.id }
      expect(response.code).to eq('200')
    end
  end

  describe 'Edit Page' do
    it 'allows editing category details' do
      category = create(:category)

      get :edit, params: { id: category.id }
      expect(response.code).to eq('200')
    end
  end
end


