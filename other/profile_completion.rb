  def profile_completion
    user = User.find(params[:id])
    total_columns = user_attribute_names_without_string_values(user).size + background_verification_attribute_names_without_status.size
    filled_columns = user_fields_blank_or_empty(user)
    if user.background_verification.present?
      non_empty_values = background_verification_fields_blank_or_empty(user)
      filled_columns += non_empty_values
    end
    profile_completion = (filled_columns.to_f / total_columns.to_f) * 100
    render json: { profile_completion: profile_completion.round(2) }
  end
