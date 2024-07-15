  def index
    if current_user
      query_param = params[:query]
      applicant_status = params[:status]
      job_opening_id = params[:job_opening_id]
      @job_applications = JobApplication.all.order(created_at: :desc)
      if query_param.present?
        @q = JobApplication.ransack(search_params(query_param))
        @job_applications = @q.result(distinct: true).order(created_at: :desc)
      end
      if applicant_status.present?
        @job_applications = JobApplication.where(applicant_status: applicant_status).order(created_at: :desc)
      end
      if applicant_status.present? && query_param.present?
        @q = JobApplication.ransack(search_params(query_param))
        @job_applications = @q.result(distinct: true).where(applicant_status: applicant_status).order(created_at: :desc)
      end
      if applicant_status.present? && query_param.present? && job_opening_id.present?
        @q = JobApplication.ransack(search_params(query_param))
        @job_applications = @q.result(distinct: true)
                              .where(applicant_status: applicant_status)
                              .where(job_opening_id: job_opening_id)
                              .order(created_at: :desc)
      end

      if params[:job_titles].present?
        job_titles_array = params[:job_titles].tr('[]', '').split(',').map(&:strip)
        @job_applications = @job_applications.joins(:job_opening).where(job_openings: { title: job_titles_array })
      end
  
      if params[:handled_by].present?
        handled_by_array = params[:handled_by].tr('[]', '').split(',').map(&:strip).map(&:to_i)
        @job_applications = @job_applications.where("handled_by && ARRAY[?]::integer[]", handled_by_array)
      end
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10
      pagy, paginated_job_applications = pagy(@job_applications, items: per_page, page: page)
      job_applications_with_resumes = paginated_job_applications.map do |job_application|
        job_application_data = JobApplicationSerializer.new(job_application).as_json
        job_application_data[:resume_url] = resume_info(job_application)
        job_application_data
      end
      render json: {
        job_applications: job_applications_with_resumes,
        pagination_data: {
          total_count: pagy.count,
          current_page: pagy.page,
          total_pages: pagy.pages,
          items_per_page: pagy.items
        }
      }, status: :ok
    else
      render json: { error: "You are not authorized" }, status: :unauthorized
    end
  end
