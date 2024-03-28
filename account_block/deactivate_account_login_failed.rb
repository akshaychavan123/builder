template-app/app/concerns/builder_json_web_token/json_web_token_validation.rb

===============================================================================================



token = request.headers[:token] || params[:token] || params.dig(:data, :token)
begin
  @token = JsonWebToken.decode(token)
  account = AccountBlock::Account.find(@token.id)

  unless account.activated
    return render json: { errors: [account: 'Account is deactivated'] }, status: :unauthorized
  end
rescue *ERROR_CLASSES => exception
  handle_exception exception
end