module  BxBlockTrafficsources2 
	class TrafficSource <  BxBlockTrafficsources2::ApplicationRecord
		self.table_name = :bx_block_trafficsources2_traffic_sources
		validates :platform, :campaign_name, presence: true

	end
end


admin panel ==============================================================================================================

ActiveAdmin.register BxBlockTrafficsources2::TrafficSource, as: "TrafficSource" do
    permit_params :platform, :code, :url, :campaign_name, :visits
  
  
      index do
          selectable_column
          id_column
          column :platform
          column :campaign_name
          column :code
          column :url
          column :visits
          actions
      end
  
      form do |f|
          f.inputs do
            f.input :platform
            f.input :campaign_name
            f.input :code
            f.input :visits, input_html: { readonly: true }
          end
          f.actions
        end
  
        show do
          attributes_table do
            row :id
            row :platform
            row :campaign_name
            row :code
            row :url
            row :visits
          end
        end
  
        controller do
          before_action :set_url, only: [:create, :update]
  
          private
  
          def set_url
  
            platform = params[:bx_block_trafficsources2_traffic_source][:platform]
            campaign_name = params[:bx_block_trafficsources2_traffic_source][:campaign_name]
            url = "https://usenamifinal2-360269-react.b360269.dev.eastus.az.svc.builder.cafe?platform=#{platform}&campaign=#{campaign_name}"
            params[:bx_block_trafficsources2_traffic_source][:url] = url
  
          end
      end
  
  end
========================================================================================================================================================

controller.rb ==========================================================================================================================================

module BxBlockTrafficsources2
	class TrafficSourcesController < ApplicationController

		def index
			@trafic_sources= BxBlockTrafficsources2::TrafficSource.all
        	render json: BxBlockTrafficsources2::TrafficSourceSerializer.new(@trafic_sources).serializable_hash, status: :ok

		end


		def update_visits
		 	@traffic_source = BxBlockTrafficsources2::TrafficSource.find_by("LOWER(platform) = ? AND LOWER(campaign_name) = ?", traffic_params[:platform]&.downcase, traffic_params[:campaign]&.downcase)

			if @traffic_source.present?
				@traffic_source.increment!(:visits)
			    render json: BxBlockTrafficsources2::TrafficSourceSerializer.new(@traffic_source).serializable_hash, status: :ok
		    	
		  	else
			   render json: { message: 'Data not found' }, status: :not_found
		  	end

		end

		private

		def traffic_params
		  params.permit(:platform, :campaign)
		end

	end
end

===========================================================================================================================================
migration.rb=========================================================================================================================


class CreateBxBlockTrafficsources2TrafficSources < ActiveRecord::Migration[6.0]
    def change
      create_table :bx_block_trafficsources2_traffic_sources do |t|
  
      t.string :platform
          t.string :code
          t.string :url
          t.string :campaign_name
          t.integer :visits , default: 0
  
            t.timestamps
      end
    end
  end
===============================================================================================================================================

admin specs =================================================================================================================================

require 'rails_helper'
require 'spec_helper'
include Warden::Test::Helpers

RSpec.describe Admin::TrafficSourcesController, type: :controller do
  render_views
   
  let(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:traffic_source) { FactoryBot.create(:traffic_source) }

  before do
    sign_in admin_user
  end

  describe "Get#index" do
    it "displays a list of content" do 
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe "Post#create" do
    let(:traffic_source1) { FactoryBot.attributes_for(:traffic_source) }

    it "create content for type traffice source" do 
      post :create, params: { "bx_block_trafficsources2_traffic_source": traffic_source1 }
      expect(response).to have_http_status(302)

    end
  end

  describe "get#new" do
    let(:traffic_source) { FactoryBot.create(:traffic_source) }

    it "create fields for type traffice source" do 
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "Get#Show" do
    it "displays a specific content" do 
      get :show, params:{ id: traffic_source.id }
      expect(response).to have_http_status(200)
    end
  end

  describe "controller" do
    describe "set_url" do
      it "sets the URL based on platform and campaign_name" do
        traffic_source_params = { bx_block_trafficsources2_traffic_source: { platform: "Platform3", campaign_name: "Campaign3" } }
        controller.params = ActionController::Parameters.new(traffic_source_params)
        
        controller.send(:set_url)

        expect(controller.params[:bx_block_trafficsources2_traffic_source][:url]).to eq("https://usenamifinal2-360269-react.b360269.dev.eastus.az.svc.builder.cafe?platform=Platform3&campaign=Campaign3")
      end
    end
  end
end
================================================================================================================================================================
factory 

FactoryBot.define do
    factory :traffic_source, class: 'BxBlockTrafficsources2::TrafficSource' do
        platform { Faker::Lorem.word }
        code { Faker::Lorem.word }
        url { Faker::Lorem.word }
        campaign_name { Faker::Lorem.word }
        visits {0}
  
      
    end
  end
=============================================================================================================================================================
controller spec=========================================================================

require 'rails_helper'

RSpec.describe BxBlockTrafficsources2::TrafficSourcesController, type: :controller do
  before(:each) do
    @traffic_source = FactoryBot.create(:traffic_source)
  end

  describe 'GET #index' do
    it 'returns a success response with traffic sources' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT #update_visits' do
    context 'with valid parameters' do
      it 'returns a success response' do
        put :update_visits, params: { platform: @traffic_source.platform, campaign: @traffic_source.campaign_name }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { platform: '', campaign: '' } }

      it 'returns a not found response' do
        put :update_visits, params: invalid_params
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
=====================================================================================================================================================
serializer.rb
module BxBlockTrafficsources2
    class TrafficSourceSerializer < BuilderBase::BaseSerializer
      attributes *[
          :id,
          :platform, 
          :code, 
          :url,
          :campaign_name,
           :visits
      ]
    end
  end
  
