model 

module BxBlockCatalogue
    class Listing < ApplicationRecord
      self.table_name = :listings
      belongs_to :category, class_name: "BxBlockCategories::Category"
      belongs_to :account, class_name: "AccountBlock::Account"
  
      has_one :private_information, class_name: "BxBlockProfile::PrivateInformation", dependent: :destroy
      has_one :summarry, class_name: "BxBlockProfile::Summarry", dependent: :destroy
      has_one :company_overview, class_name: "BxBlockProfile::CompanyOverview", dependent: :destroy
      has_one :acquisition_detail, class_name: "BxBlockProfile::AcquisitionDetail", dependent: :destroy
      has_one :financial, class_name: "BxBlockProfile::Financial", dependent: :destroy
      has_one :customer_metric, class_name: "BxBlockProfile::CustomerMetric", dependent: :destroy
  
      has_one :private_business_information, class_name: "BxBlockProfile::PrivateBusinessInformation", dependent: :destroy
      has_one :business_company_overview, class_name: "BxBlockProfile::BusinessCompanyOverview", dependent: :destroy
      has_one :business_acquisition_detail, class_name: "BxBlockProfile::BusinessAcquisitionDetail", dependent: :destroy
      has_one :business_financial, class_name: "BxBlockProfile::BusinessFinancial", dependent: :destroy
      has_one :business_customer_vendor_metric, class_name: "BxBlockProfile::BusinessCustomerVendorMetric", dependent: :destroy
    end
  end

  

  active_admin page =>>>

  ActiveAdmin.register BxBlockCatalogue::Listing, as: "Listings" do
    permit_params :name, :progress, :category_id, :account_id, :approved
    
    index do
      column :name
      column :progress
      column :category
      column "Account Email" do |listing|
        listing.account&.email
      end
      column :approved
      actions
    end
  
    show do
      attributes_table do
        row :name
        row :progress
        row :category
        row :account_email do
          resource.account&.email
        end
        row :approved
      end
      # resource.category&.name.downcase
  
      if resource.category&.name.downcase == "start up"
  
        panel "Startup Information" do
  
          panel "Private Information" do
            
            attributes_table_for resource.private_information do
              BxBlockProfile::PrivateInformation.columns.each do |column|
                row column.name
              end
            end
          end
  
          panel "Summarry" do
            attributes_table_for resource.summarry do
              BxBlockProfile::Summarry.columns.each do |column|
                row column.name
              end
            end
          end
  
          panel "Company Overview" do
            attributes_table_for resource.company_overview do
              BxBlockProfile::CompanyOverview.columns.each do |column|
                row column.name
              end
            end
          end
  
          panel "Acquisition Detail" do
            attributes_table_for resource.acquisition_detail do
              BxBlockProfile::AcquisitionDetail.columns.each do |column|
                row column.name
              end
            end
          end
  
          panel "Financial" do
            attributes_table_for resource.financial do
              BxBlockProfile::Financial.columns.each do |column|
                row column.name
              end
            end
          end
  
          panel "Customer Metric" do
            attributes_table_for resource.customer_metric do
              BxBlockProfile::CustomerMetric.columns.each do |column|
                row column.name
              end
            end
          end
          
        end
      elsif resource.category&.name.downcase == "business"
  
        panel "Business Information" do
          panel "Private Business Information" do
            attributes_table_for resource.private_business_information do
              BxBlockProfile::PrivateBusinessInformation.columns.each do |column|
                row column.name
              end
            end
          end
  
          panel "Summarry" do
            attributes_table_for resource.summarry do
              BxBlockProfile::Summarry.columns.each do |column|
                row column.name
              end
            end
          end
      
          panel "Business Company Overview" do
            attributes_table_for resource.business_company_overview do
              BxBlockProfile::BusinessCompanyOverview.columns.each do |column|
                row column.name
              end
            end
          end
      
          panel "Business Acquisition Detail" do
            attributes_table_for resource.business_acquisition_detail do
              BxBlockProfile::BusinessAcquisitionDetail.columns.each do |column|
                row column.name
              end
            end
          end
      
          panel "Business Financial" do
            attributes_table_for resource.business_financial do
              BxBlockProfile::BusinessFinancial.columns.each do |column|
                row column.name
              end
            end
          end
      
          panel "Business Customer Vendor Metric" do
            attributes_table_for resource.business_customer_vendor_metric do
              BxBlockProfile::BusinessCustomerVendorMetric.columns.each do |column|
                row column.name
              end
            end
          end
  
        end
      end
  
    end 
  
    form do |f|
      f.inputs do
        f.input :name
        f.input :progress
        f.input :category
        f.input :approved
      end
      f.actions
    end
  end

  

  rspec test cases ====>>>>


  require 'rails_helper'
require 'spec_helper'
include Warden::Test::Helpers

RSpec.describe Admin::ListingsController, type: :controller do
  render_views

  let(:admin_user) { FactoryBot.create(:admin_user) }
  let(:listing) { FactoryBot.create(:bx_block_catalogue_listing) }

  before(:each) do
    @user = FactoryBot.create(:email_account)
    @category = FactoryBot.create(:category)
    @sub_category = FactoryBot.create(:sub_category)
    @category = FactoryBot.create(:category, name: "starT up")
    @category1 = FactoryBot.create(:category, name: "BusinesS")

    @listing = FactoryBot.create(:listing, account_id: @user.id, category_id: @category.id)
    @listing = FactoryBot.create(:listing, account_id: @user.id, category_id: @category.id)
    @financial = FactoryBot.create(:financial,listing_id: @listing.id)
    @customer_metric = FactoryBot.create(:customer_metric, listing_id: @listing.id)
    @company_overview = FactoryBot.create(:company_overview, listing_id: @listing.id)
    @private_information = FactoryBot.create(:private_information, listing_id: @listing.id)
    @acquisition_detail = FactoryBot.create(:acquisition_detail, listing_id: @listing.id)
    @customer_metric = FactoryBot.create(:business_customer_vendor_metric, listing_id: @listing.id)
    @summarry = FactoryBot.create(:summarry, listing_id: @listing.id, sub_category_id: @sub_category.id)

    
    @listing1 = FactoryBot.create(:listing, account_id: @user.id, category_id: @category1.id)
    @financial = FactoryBot.create(:financial,listing_id: @listing1.id)
    @customer_metric = FactoryBot.create(:customer_metric, listing_id: @listing1.id)
    @company_overview = FactoryBot.create(:company_overview, listing_id: @listing1.id)
    @private_information = FactoryBot.create(:private_information, listing_id: @listing1.id)
    @acquisition_detail = FactoryBot.create(:acquisition_detail, listing_id: @listing1.id)
    @customer_metric = FactoryBot.create(:business_customer_vendor_metric, listing_id: @listing1.id)
    @summarry = FactoryBot.create(:summarry, listing_id: @listing.id, sub_category_id: @sub_category.id)
  end

  before do
    sign_in admin_user
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get :show, params: { id: @listing.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show for business' do
    it 'renders business the show template' do
      get :show, params: { id: @listing1.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #new' do
    let(:listing_params) { FactoryBot.create(:listing) }
    it 'renders the new template' do
      get :new
      expect(response).to have_http_status(200)
    end
  end


end


========>>>>>>

controller code ====>>>>>>>>>>>


module BxBlockCatalogue
    class ListingsController < ApplicationController
      before_action :current_user
      before_action :set_list_id, only: [:update_list, :get_list]
      STARTUP_CATEGORY_NAME = "start up".freeze
  
      def user_list
        list = @account.listings.all
        if list.present?
          render json: BxBlockCatalogue::ListingSerializer.new(list).serializable_hash, status: :ok
        else
          render json: {error: "Not list Exist"}
        end
      end
  
      def get_list
        if @listing.name.downcase == STARTUP_CATEGORY_NAME
          render json: BxBlockCatalogue::StartUpSerializer.new(@listing).serializable_hash, status: :ok
        else
          render json: BxBlockCatalogue::BusinessSerializer.new(@listing).serializable_hash, status: :ok
        end
      end
  
      def index
        category_id_to_filter = params[:category_id]
        sub_category_id_to_filter = params[:sub_category_id]
  
        @listings = BxBlockCatalogue::Listing.includes(
          :private_information, :summarry, :company_overview,
          :acquisition_detail, :financial, :customer_metric,
          :private_business_information, :business_company_overview,
          :business_acquisition_detail, :business_financial,
          :business_customer_vendor_metric
        )
      
        if category_id_to_filter.present? && sub_category_id_to_filter.present?
  
          @listings = @listings.where(category_id: category_id_to_filter)
                             .joins(:summarry)
                             .where('summarries.sub_category_id' => sub_category_id_to_filter)
        end
        @rendered_data = render_listings_data(@listings)
        render json: @rendered_data
      end
      
  
      def update_list
        if @listing.update(progress: params["percent"])
          render json: BxBlockCatalogue::ListingSerializer.new(@listing, meta: { message: "Successfully Updated"}).serializable_hash, status: :ok
        end  
      end
  
      def create_listing
        @category = BxBlockCategories::Category.find_by(id: params["category_id"])
        return render json: { error: "invalid category id" } unless @category.present?
  
        @listing = current_user.listings.build(category_id: @category.id, name: @category.name)
  
        begin
          ActiveRecord::Base.transaction do
            build_associated_models(@listing)
            @listing.save!
            save_associated_objects(@listing, @category.name.downcase)
          end
  
          render json: { message: "#{@category.name} added successfully to the list" }
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
  
      private
  
      def set_list_id
        @listing = BxBlockCatalogue::Listing.find_by(id: params["listing_id"])
        return render json: { error: "invalid list id" } if !@listing.present?
      end
  
      def current_user
        @account = AccountBlock::Account.find_by(id: @token.id)
      end
  
      def build_associated_models(listing)
        case @category.name.downcase
        when STARTUP_CATEGORY_NAME
          build_startup_associated_models(listing)
        when "business"
          build_business_associated_models(listing)
        else
          # Handle other categories if needed
        end
      end
  
      def build_startup_associated_models(listing)
        listing.build_private_information
        listing.build_summarry
        listing.build_company_overview
        listing.build_acquisition_detail
        listing.build_financial
        listing.build_customer_metric
      end
  
      def build_business_associated_models(listing)
        listing.build_private_business_information
        listing.build_summarry
        listing.build_business_company_overview
        listing.build_business_acquisition_detail
        listing.build_business_financial
        listing.build_business_customer_vendor_metric
      end
  
      def save_associated_objects(listing, category_type)
        case category_type
        when STARTUP_CATEGORY_NAME
          save_startup_associated_objects(listing)
        when "business"
          save_business_associated_objects(listing)
        else
          # Handle other categories if needed
        end
      end
  
      def save_startup_associated_objects(listing)
        listing.private_information.save!
        listing.summarry.save!
        listing.company_overview.save!
        listing.acquisition_detail.save!
        listing.financial.save!
        listing.customer_metric.save!
      end
  
      def save_business_associated_objects(listing)
        listing.private_business_information.save!
        listing.summarry.save!
        listing.business_company_overview.save!
        listing.business_acquisition_detail.save!
        listing.business_financial.save!
        listing.business_customer_vendor_metric.save!
      end
  
      def render_listings_data(listings)
        data = listings.map do |listing|
          private_information_data = {}
      
          if listing.private_information.present?
            private_information_data = {
              startup_name: listing.private_information.startup_name,
              startup_website: listing.private_information.startup_website,
              question: listing.private_information.question,
              answer: listing.private_information.answer,
              auto_sign_nda: listing.private_information.auto_sign_nda,
              auto_accept_request: listing.private_information.auto_accept_request,
              listing_id: listing.private_information.listing_id,
              p_and_l_statements: listing.private_information.p_and_l_statements.map { |document| { file_path: Rails.application.routes.url_helpers.rails_blob_url(document, only_path: true) }},
              documents: listing.private_information.document_titles.map { |document| { document_title: document.title, file_path: Rails.application.routes.url_helpers.rails_blob_url(document.document, only_path: true) }}
            }
          end
      
          business_private_information_data = {}
      
          if listing.private_business_information.present?
            business_private_information_data = {
              company_name: listing.private_business_information.company_name,
              company_website: listing.private_business_information.company_website,
              work_with_vendors: listing.private_business_information.work_with_vendors,
              already_commitments: listing.private_business_information.already_commitments,
              total_depth: listing.private_business_information.total_depth,
              total_assets: listing.private_business_information.total_assets,
              total_shareholder_equity: listing.private_business_information.total_shareholder_equity,
              auto_sign: listing.private_business_information.auto_sign,
              auto_accept_request: listing.private_business_information.auto_accept_request,
              listing_id: listing.private_business_information.listing_id,
              suppliers_and_vendors_contract: listing.private_business_information.suppliers_and_vendors_contract.attached? ? Rails.application.routes.url_helpers.rails_blob_url(listing.private_business_information.suppliers_and_vendors_contract, only_path: true) : nil,
              balance_sheet: listing.private_business_information.balance_sheet.map { |document| Rails.application.routes.url_helpers.rails_blob_url(document, only_path: true) },
              p_and_l_statement: listing.private_business_information.p_and_l_statement.attached? ? Rails.application.routes.url_helpers.rails_blob_url(listing.private_business_information.p_and_l_statement, only_path: true) : nil,
              documents: listing.private_business_information.doc_titles.map { |document| { document_title: document.title, file_path: Rails.application.routes.url_helpers.rails_blob_url(document.document, only_path: true) }}
            }
          end
  
          subcategory_data = {}
  
          if listing.summarry&.subcategory.present?
            subcategory = listing.summarry.subcategory
            subcategory_data = {
              id: listing.id,
              name: listing.name,
              progress: listing.progress,
              approved: listing.approved,
              category_id: listing.category_id,
              subcategory_id: subcategory.id,
              subcategory_name: subcategory.name
              # subcategory_icon_url: Rails.application.routes.url_helpers.rails_blob_url(subcategory.icon, only_path: true)
            }
          end
  
          {
            listing: subcategory_data,
            privateinformation: business_private_information_data.present? ? business_private_information_data : nil,
            private_information: private_information_data.present? ? private_information_data : nil,
            summarry: listing.summarry,
            company_overview: listing.company_overview,
            acquisition_detail: listing.acquisition_detail,
            financial: listing.financial,
            customer_metric: listing.customer_metric,
            company_overview: listing.business_company_overview,
            acquisition_detail: listing.business_acquisition_detail,
            financial: listing.business_financial,
            customer_metric: listing.business_customer_vendor_metric,
  
          }.compact
        end
      
        return data
      end
      
        
  
    end
  end

  

  ===========================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  module BxBlockProfile
    class StartUpsController < ApplicationController
      NO_DATA_EXIST_ERROR = "No data exist".freeze
  
      before_action :current_user
      # before_action :find_account_by_catalogue_id, only:[:get_financial,:get_private_information,:get_summarry,:get_acquisition_detail,:get_customer_metric]
      # before_action :set_private_information, only: [:update_private_informations]
      before_action :set_list_id, only: [:update_private_informations, :update_summarry, :update_company_profile, :update_acquisition_detail,
      :update_financial, :update_customer_metric, :get_acquisition_detail, :get_financial, :get_customer_metric, :get_private_information, :get_summarry, :get_company_overview]
  
      def get_acquisition_detail
        acquisition_detail = @listing.acquisition_detail
        return render json: { error: NO_DATA_EXIST_ERROR } unless acquisition_detail
        render_json_or_error(BxBlockProfile::AcquisitionDetailSerializer, acquisition_detail)
      end
  
      def get_financial
        financial = @listing.financial
        return render json: { error: NO_DATA_EXIST_ERROR } unless financial
        render_json_or_error(BxBlockProfile::FinancialSerializer, financial)
      end
  
      def get_customer_metric
        customer_metric = @listing.customer_metric
        return render json: { error: NO_DATA_EXIST_ERROR } unless customer_metric
        render_json_or_error(BxBlockProfile::CustomerMetricSerializer, customer_metric)
      end
  
      def get_private_information
        private_information = @listing.private_information
        return render json: { error: NO_DATA_EXIST_ERROR } unless private_information
        render_json_or_error(BxBlockProfile::PrivateInformationSerializer, private_information)
      end
  
      def get_summarry
        summarry = @listing.summarry
        return render json: { error: NO_DATA_EXIST_ERROR } unless summarry
        render_json_or_error(BxBlockProfile::SummarrySerializer, summarry)
      end
  
      def get_company_overview
        a = {}
        a[:company_overview] = @listing.company_overview
        a[:list_of_products] = @listing.company_overview.list_of_products
        a[:company_key_asset] = @listing.company_overview.company_key_asset
        a[:growth_opportunity] = @listing.company_overview.company_growth_opportunity
        render json: a
      end
  
      def update_private_informations
        @private_information = @listing.private_information
        if @private_information.update(private_information_params)
          render json: BxBlockProfile::PrivateInformationSerializer.new(@private_information, serialize_options).serializable_hash, status: :ok
        end
      end
  
      def update_summarry
        @summarry = @listing.summarry
        debugger
        if @summarry.update(summary_params)
          render json: BxBlockProfile::SummarrySerializer.new(@summarry, serialize_options).serializable_hash, status: :ok
        # else
        #   render json: @summarry.errors, status: :unprocessable_entity
        end
      end
  
      def update_acquisition_detail
        acquisition_detail = @listing.acquisition_detail
        if acquisition_detail.update(acquisition_detail_params)
          render json: BxBlockProfile::AcquisitionDetailSerializer.new(acquisition_detail, serialize_options).serializable_hash, status: :ok
        # else
        #   render json: { errors: { reason_for_selling: acquisition_detail.errors.full_messages } }, status: :unprocessable_entity
        end
      end
  
      def update_financial
        financial = @listing.financial
        if financial.update(financial_params)
          render json: BxBlockProfile::FinancialSerializer.new(financial, serialize_options).serializable_hash, status: :ok
        else
          render json: financial.errors, status: :unprocessable_entity
        end
      end
  
      def update_customer_metric
        customer_metric = @listing.customer_metric
        if customer_metric.update(customer_metric_params)
          render json: BxBlockProfile::CustomerMetricSerializer.new(customer_metric, serialize_options).serializable_hash, status: :ok
        else
          render json: { errors: customer_metric.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def update_company_profile
        errors = []
        company_profile = {}
        listing_id = params[:listing_id]
        ActiveRecord::Base.transaction do
          company_overview = create_company_overview(@listing)
          errors << company_overview[:error]
          company_profile[:company_overview] = company_overview[:company_overview]
          list_of_product = create_list_of_product(@listing)
          company_profile[:list_of_product] = list_of_product
          company_key_asset = create_company_key_asset(@listing)
          company_profile[:company_key_asset] = company_key_asset[:company_key_asset]
          errors << company_key_asset[:error]
          growth_opportunity = create_company_growth_opportunity(@listing)
          company_profile[:growth_opportunity] = growth_opportunity[:company_growth_opportunity]
          errors << growth_opportunity[:error]
          raise ActiveRecord::Rollback unless errors.all?(&:nil?)
        end
        render_response(errors, company_profile)
      end
  
      def buyer_profile
        render json: AccountBlock::EmailAccountSerializer.new(@account, serialize_options).serializable_hash, status: 200
      end
  
      def user_subscription_plan
        @user_subscription_plan = BxBlockSubscriptions::SubscriptionPlan.find_by(id: params[:subscription_plan_id])
        if @user_subscription_plan.present?
          user_subscription = @account.user_subscription_plans.build(subscription_plan_id: params[:subscription_plan_id])
          if user_subscription.valid?
            user_subscription.save
            render json: { message: "successfully subscribed"}
          end  
        else
          render json: { error: "Invalid Subcription Plan Id"}   
        end
      end
  
      private
  
      def set_list_id
        @listing = BxBlockCatalogue::Listing.find_by(id: params["listing_id"])
        return render json: { error: "invalid list id" } if !@listing.present?
      end
  
      def render_json_or_error(serializer, data)
        if data
          render json: serializer.new(data, serialize_options).serializable_hash, status: :ok
        else
          render json: { error: 'Data not found' }, status: :not_found
        end
      end
  
      def set_private_information
        @private_information = BxBlockProfile::PrivateInformation.find(params[:id])
      end
  
      def current_user
        @account = AccountBlock::Account.find_by(id: @token.id)
      end
  
      def acquisition_detail_params
        params.require(:acquisition_detail).permit(
          :reason_for_selling,:angel_investor,:incubators_accelerators,:vc_backed,
          :bootstrap_self_funded,:corporate_funded,:other)
      end
  
      def summary_params
        params.require(:summarry).permit(:date_founded, :startup_team_size, :country, :description, :asking_price, :asking_price_reasoning, :headline, :city, :sub_category_id)
      end
  
      def company_growth_opportunity_params
        params.require(:company_growth_opportunity).permit(
          :improve_conversion_rates, :increase_content_marketing, :expand_to_new_markets, :increase_pricing,
          :hire_b2b_sales_team, :focus_on_seo, :increase_digital_marketing, :add_new_product_features,
          :social_media_marketing, :other)
      end
  
      def company_key_asset_params
        params.require(:company_key_asset).permit( :codebase_and_ip, :social_media_accounts, :customers, :website, :marketing_materials, :mobile_application, :brand, :domain,:other)
      end
  
      def company_overview_params
        params.require(:company_overview).permit(:question1, :answer1, :question2, :answer2)
      end
  
      def financial_params
        params.require(:financial).permit(:ltm_gross_revenue, :ltm_net_profit, :annual_recurring_revenue, :annual_growth_rate, :last_month_gross_revenue, :last_month_net_profit, :multiple_type, :multiple_number)
      end
  
      def customer_metric_params
        params.require(:customer_metric).permit(:number_of_users)
      end  
  
      def private_information_params
        params.require(:private_information).permit(:startup_name, :startup_website, :auto_sign_nda, :question, :answer, :auto_accept_request, p_and_l_statements: [],document_titles_attributes: [:title, :document])
      end
  
      def list_of_product_params
        params.require(:list_of_product).map { |product_params| product_params.permit(:name).merge(account_id: @account.id) }
      end
  
      def render_response(errors, company_profile)
        if errors.any?
          render json: { errors: errors.compact }, status: :unprocessable_entity
        else
          render json: company_profile
  
        end
      end
  
      def create_company_overview(listing)
        company_overview = {}
        @company_overview = listing.company_overview # Use build_association instead of new
        if @company_overview.update(company_overview_params)
          company_overview[:company_overview] = @company_overview
          company_overview[:error] = nil
        else
          company_overview[:company_overview] = nil
          company_overview[:error] = @company_overview.errors.full_messages.to_sentence
        end
        company_overview
      end
  
      def create_list_of_product(listing)
        @company_overview = listing.company_overview
        @company_overview.list_of_products.destroy_all if @company_overview.list_of_products
        product_params = params[:list_of_product]
        list_of_products = product_params.map { |product| { name: product[:name], company_overview_id: @company_overview.id } }
        @company_overview.list_of_products.build(list_of_products)
        @company_overview.save
        @company_overview.list_of_products
      end
  
  
      def create_company_key_asset(listing)
        company_key_asset = {}
        @company_key_asset = listing.company_overview.build_company_key_asset(company_key_asset_params)
        if @company_key_asset.valid?
          @company_key_asset.save
          company_key_asset[:company_key_asset] = @company_key_asset
          company_key_asset[:error] = nil
        else
          company_key_asset[:company_key_asset] = nil
          company_key_asset[:error] = @company_key_asset.errors.full_messages.to_sentence
        end  
        company_key_asset
      end
  
      def create_company_growth_opportunity(listing)
        company_growth_opportunity = {}
        @company_growth_opportunity = listing.company_overview.build_company_growth_opportunity(company_growth_opportunity_params)
        if @company_growth_opportunity.valid?
          @company_growth_opportunity.save
          company_growth_opportunity[:company_growth_opportunity] = @company_growth_opportunity
          company_growth_opportunity[:error] = nil
        else
          company_growth_opportunity[:company_growth_opportunity] = nil
          company_growth_opportunity[:error] = @company_growth_opportunity.errors.full_messages.to_sentence
        end
        company_growth_opportunity
      end
  
      def serialize_options
        {params: {host: request.protocol + request.host_with_port }}
      end
    end      
  end

  



  serializer=============================>>>>>>>>>>>>>>>>>>
  module BxBlockCatalogue
    class StartUpSerializer < BuilderBase::BaseSerializer
      attributes :id, :name, :progress, :category_id, :account_id
  
      attribute :private_information do |listing|
        listing.private_information
      end
  
      attribute :summarry do |listing|
        listing.summarry
      end
  
      attribute :company_overview do |listing|
        listing.company_overview
      end
  
      attribute :acquisition_detail do |listing|
        listing.acquisition_detail
      end
  
      attribute :financial do |listing|
        listing.financial
      end
  
      attribute :customer_metric do |listing|
        listing.customer_metric
      end
  
    end
  end
===============================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

RAILS HELPER FILE ===========================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper' 
require 'mock_redis'
require_relative '../config/environment'
ENV['RAILS_ENV'] ||= 'test'
#require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# require 'support/factory_bot'
if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails'
  puts "required simplecov"
end
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
  RSpec.configure do |config|
    config.include(Shoulda::Callback::Matchers::ActiveModel)
  end
  
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include FactoryBot::Syntax::Methods
end


++++++++++++++++++++++=========================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

SPEC HELPER FILE===================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

require 'simplecov'
require 'simplecov-json'
ENV['RAILS_ENV'] ||= 'test'

# SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter

SimpleCov.start('rails')  do
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Admins", "app/admin"
  add_group "Multiple Files", ["app/models", "app/controllers"] # You can also pass in an array
  add_group "bx_blocks", %r{bx_block.*}
  add_filter %r{vendor/ruby/ruby/2.*}
end
# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
  #config.include AuthenticationHelper
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  # https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end


=====================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>





controller code spec file ========================?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


require 'rails_helper'

RSpec.describe BxBlockCatalogue::ListingsController, type: :controller do

  before(:each) do
    @user = FactoryBot.create(:email_account)
    @sub_category = FactoryBot.create(:sub_category)
    @category = FactoryBot.create(:category, name: "start up")
    @category1 = FactoryBot.create(:category, name: "Business")
    @listing = FactoryBot.create(:listing, name: "start up", account_id: @user.id, category_id: @category.id)
    @listing1 = FactoryBot.create(:listing, name: "Business", account_id: @user.id, category_id: @category1.id)
    @user1 = FactoryBot.create(:email_account)
    @token = BuilderJsonWebToken.encode(@user.id)
    @token1 = BuilderJsonWebToken.encode(@user1.id)

    @financial = FactoryBot.create(:financial,listing_id: @listing.id)
    @customer_metric = FactoryBot.create(:customer_metric, listing_id: @listing.id)
    @company_overview = FactoryBot.create(:company_overview, listing_id: @listing.id)
    @private_information = FactoryBot.create(:private_information, listing_id: @listing.id)
    @acquisition_detail = FactoryBot.create(:acquisition_detail, listing_id: @listing.id)
    @customer_metric = FactoryBot.create(:business_customer_vendor_metric, listing_id: @listing.id)
    @summarry = FactoryBot.create(:summarry, listing_id: @listing.id, sub_category_id: @sub_category.id)

    @financial = FactoryBot.create(:financial,listing_id: @listing1.id)
    @customer_metric = FactoryBot.create(:customer_metric, listing_id: @listing1.id)
    @company_overview = FactoryBot.create(:company_overview, listing_id: @listing1.id)
    @private_information = FactoryBot.create(:private_information, listing_id: @listing1.id)
    @acquisition_detail = FactoryBot.create(:acquisition_detail, listing_id: @listing1.id)
    @customer_metric = FactoryBot.create(:business_customer_vendor_metric, listing_id: @listing1.id)
    @summarry = FactoryBot.create(:summarry, listing_id: @listing1.id, sub_category_id: @sub_category.id)
  end

  describe 'GET #user_list' do
    it 'returns a successful response' do
      get :user_list ,params: { token: @token }
      expect(response).to have_http_status(:ok)
    end

    it 'returns an error if no listings exist' do
      get :user_list ,params: { token: @token1 }
      expect(JSON.parse(response.body)).to include('error' => 'Not list Exist')
    end
  end
  
  describe 'GET #get_list' do
    it 'returns a successful response for start up' do
      get :get_list ,params: { listing_id: @listing.id,token: @token }
      expect(response).to have_http_status(:ok)
    end

    it 'returns a successful response for business' do
      get :get_list ,params: { listing_id: @listing1.id,token: @token }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index ,params: { token: @token }
      expect(response).to have_http_status(:ok)
    end

    it 'returns a successful response with category and subcategory' do
      get :index ,params: { category_id: @category.id, sub_category_id: @sub_category.id ,token: @token }
      expect(response).to have_http_status(:ok)
    end

  end

  describe 'PATCH #update_list' do
    it 'updates the progress of the listing' do
      put :update_list, params: { listing_id: @listing.id, percent: 50, token: @token }
      expect(response).to have_http_status(:ok)  
    end
  end

  describe 'POST #create_listing start up' do
    context 'with valid parameters' do
      it 'creates a new listing and associated models' do
        post :create_listing, params: { category_id: @category.id, token: @token }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post :create_listing, params: { category_id: 9999, token: @token }
        # expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error' => 'invalid category id')
      end
    end
  end

  describe 'POST #create_listing business' do
    context 'with valid parameters' do
      it 'creates a new listing and associated models' do
        post :create_listing, params: { category_id: @category1.id, token: @token }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST #create_listing' do
    context 'with invalid parameters' do
      it 'returns an error message for invalid record creation' do
        allow_any_instance_of(BxBlockCatalogue::Listing).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(BxBlockCatalogue::Listing.new))
        post :create_listing, params: { category_id: @category.id, token: @token }
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Validation failed: ")
      end
    end
  end

end














