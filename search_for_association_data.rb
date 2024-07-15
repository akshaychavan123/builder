suppose user has many designations and designation has many departments
user == designation_id
designation == department_id


  def index
    if current_user
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10
      query_param = params[:query]
      @departments = Department.all.order(created_at: :desc)
      if query_param.present?
        @q = Department.ransack(search_params(query_param))
        @departments = @q.result(distinct: true).order(created_at: :desc)
      end
      pagy, paginated_departments = pagy(@departments, items: per_page, page: page)
      department_data = paginated_departments.map do |department|
        {
          id: department.id,
          name: department.name,
          created_date: department.created_date.strftime("%d %b %Y, %I:%M %p"),
          created_by_id: department.created_by_id,
          created_by: department.created_by.full_name,
          designations: department.designations.map do |designation|
            {
              id: designation.id,
              designation: designation.designation,
              users: designation.users.map { |user| { id: user.id, full_name: user.full_name } }
            }
          end
        }
      end
      render json: {
        message: "Departments listing are as follows",
        totalCount: pagy.count,
        departments: department_data,
        currentPage: pagy.page,
        totalPages: pagy.pages,
        success: true
      }, status: :ok
    else
      render json: { message: 'You are not authorized', success: false }, status: :unauthorized
    end
  end



private

  def search_params(query_param)
    fields_to_search = %w[name created_date]
    search_conditions = fields_to_search.map do |field|
      { "#{field}_cont" => query_param }
    end
  
    if query_param.present? && !query_param.match?(/^\d+$/)
      # Find designation names matching the query
      designation_names = Designation.where('designation ILIKE ?', "%#{query_param}%").pluck(:designation)
  
      unless designation_names.empty?
        # Find department names that have designations matching the names
        department_names = Department.joins(:designations)
                                      .where('designations.designation IN (?)', designation_names)
                                      .pluck(:name)
        unless department_names.empty?
          search_conditions << { 'name_in' => department_names }
        end
      end
    end
  
    { 'combinator' => 'or', 'groupings' => search_conditions }
  end


#you can add up many relation required for data listings

in model ================================================


  def self.ransackable_attributes(auth_object = nil)
    %w[name created_date created_by_id designation_id]
  end



