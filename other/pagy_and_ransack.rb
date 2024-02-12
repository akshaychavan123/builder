gem 'pagy'
gem 'ransack'


ApplicationController===>>

include Pagy::Backend

users controllers

def index
    user_type = params[:user_type]
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10
    if current_user.has_role?(:admin)
      query_param = params[:query]
      @q = User.ransack(search_params(query_param))
      case user_type
      when "all"
        @users = @q.result(distinct: true)
      when "active"


private method ===>>> for searching will all columns


def search_params(query_param)
    fields_to_search = %w[full_name email father_name mother_name linkedin_profile contact_no personal_email blood_group marital_status date_of_birth uan_no esic_no employee_id employee_type job_type date_of_joining relieving_date resignation_date resignation_status notice_period retention_bonus retention_time retention_bonus_no gender city pincode state address designation emergency_contact_no emp_code profile_picture_url section_applicable country]
  
    search_conditions = fields_to_search.map do |field|
      { "#{field}_cont" => query_param }
    end
    { 'combinator' => 'or', 'groupings' => search_conditions }
  end


in user model ===>>


    def self.ransackable_attributes(auth_object = nil)
        %w[full_name email father_name mother_name linkedin_profile contact_no personal_email blood_group marital_status date_of_birth uan_no esic_no employee_id employee_type job_type date_of_joining relieving_date resignation_date resignation_status notice_period retention_bonus retention_time retention_bonus_no gender city pincode state address designation emergency_contact_no emp_code profile_picture_url section_applicable country]
      end
      def self.ransackable_associations(auth_object = nil)
        []
      end