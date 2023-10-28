
require 'rails_helper'
RSpec.describe AccountBlock::AccountsController, type: :controller do
 TEST_EMAIL = 'john@example.com'
 TEST_PASSWORD = '8395@Prin'
 let(:account) { FactoryBot.create(:account, activated: true) }
 let(:signup_url) { '/account/accounts' }
 let(:verify_url) { '/account_block/accounts/verify_sms_otp' }
 let(:validation_url) { '/account_block/accounts/check_validations' }
 let(:full_phone_number) { '919898989898' }
 let(:email) { 'johnn@yopmail.com' }

 describe 'create' do
 it 'when pass the correct params with data_type is email' do
 post :create,
 params: { data: { type: 'email_account',
 attributes: { email: TEST_EMAIL, first_name: 'John', last_name: 'Singh',
 full_phone_number: '919898989898', activated: true, password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(201)
 end

 it 'when email is blank' do
 post :create,
 params: { data: { type: 'email_account',
 attributes: { email: '', first_name: 'John', last_name: 'Singh',
 full_phone_number: '919898989898', activated: true, password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'when email is already taken' do
 FactoryBot.create(:email_account, activated: true)
 post :create,
 params: { data: { type: 'email_account',
 attributes: { email: TEST_EMAIL, first_name: 'John', last_name: 'Singh',
 full_phone_number: '919898989898', activated: true, password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'when email is not valid' do
 post :create,
 params: { data: { type: 'email_account',
 attributes: { email: 'jhfkjhks', first_name: 'John', last_name: 'Singh',
 full_phone_number: '919898989898', activated: true, password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'when pass the correct params with data_type is sms' do
 post :create,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989898', country_code: '91' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(201)
 end

 it 'when country code is not available ' do
 post :create,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '9898989898' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'when phone number is not valid' do
 post :create,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '98kfhk9898', country_code: '91' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'when phone number already taken' do
 FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989898')
 post :create,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989898', country_code: '91' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'when pass the correct params with data_type is social account' do
 FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989898')
 post :create,
 params: { data: { type: 'social_account',
 attributes: { email: TEST_EMAIL, unique_auth_id: 'gkjhsdkjghkgiudgytadk' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(201)
 end

 it 'when social account not valid' do
 FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989898')
 post :create,
 params: { data: { type: 'social_account',
 attributes: { email: TEST_EMAIL } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'when account type is invalid' do
 post :create,
 params: { data: { type: 'social_hjlaccount',
 attributes: { email: TEST_EMAIL } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end
 end

 describe 'resend otp' do
 before do
 email_account = FactoryBot.create(:email_account, activated: false)
 sms_account = FactoryBot.create(:sms_account, activated: false, full_phone_number: '919898989897')
 end
 it 'email otp pass the correct params when activated ' do
 patch :resend_otp,
 params: { data: { type: 'email_account',
 attributes: { email: TEST_EMAIL } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(201)
 end

 it 'email otp failed' do
 patch :resend_otp,
 params: { data: { type: 'email_account',
 attributes: { email: 'johngdhkn@example.com' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'sms otp pass the correct params when activated ' do
 patch :resend_otp,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897', country_code: '91' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(201)
 end

 it 'sms otp pass the correct params when activated ' do
 patch :resend_otp,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end
 end

 describe 'verify otp' do
 context 'verify email otp' do
 before do
 @token = BuilderJsonWebToken.encode(account.id)
 end
 it 'not verify email otp because email is blank' do
 post :verify_otp,
 params: { data: { type: 'email_account',
 attributes: { email: '' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it ' not verify email otp because email not found ' do
 post :verify_otp,
 params: { data: { type: 'email_account',
 attributes: { email: 'anyemail@yopmail.com' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'invalid otp' do
 account = AccountBlock::Account.create(email: 'anyemail@yopmail.com', otp: 123456)
 post :verify_otp,
 params: { data: { type: 'email_account',
 attributes: { email: account.email, otp: 676777 } } }
 data = JSON.parse(response.body)
 expect(data["errors"]).to eq([{"message"=>"Incorrect OTP"}])
 expect(response).to have_http_status(422)
 end

 it ' not verify email otp because incorrect otp' do
 FactoryBot.create(:email_otp, email: account.email)
 post :verify_otp,
 params: { data: { type: 'email_account',
 attributes: { email: TEST_EMAIL, otp: 6856 } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it ' verify email otp' do
 @otp = FactoryBot.create(:email_otp, email: account.email)
 account.update(otp: @otp.pin)
 post :verify_otp,
 params: { data: { type: 'email_account',
 attributes: { email: account.email, otp: @otp.pin } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(200)
 end
 end

 context 'verify sms otp' do
 it 'verify sms otp' do
 sms_account = FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989897')
 post :verify_otp,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897', country_code: '91',
 otp: sms_account.otp } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(200)
 end

 it 'incorrect otp' do
 sms_account = FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989898')
 otp = FactoryBot.create(:sms_otp,
 full_phone_number: sms_account.country_code.to_s + sms_account.full_phone_number)
 sms_account.update(otp: otp.pin)
 post :verify_otp,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989898', country_code: '91', otp: 4567 } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'account not found' do
 sms_account = FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989898')
 otp = FactoryBot.create(:sms_otp,
 full_phone_number: sms_account.country_code.to_s + sms_account.full_phone_number)
 sms_account.update(otp: otp.pin)
 post :verify_otp,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989828', country_code: '91', otp: 4567 } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'country codes not found' do
 sms_account = FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989898')
 otp = FactoryBot.create(:sms_otp,
 full_phone_number: sms_account.country_code.to_s + sms_account.full_phone_number)
 sms_account.update(otp: otp.pin)
 post :verify_otp,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989828', otp: 4567 } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end
 end
 end

 describe 'create password' do
 before do
 @email_account = FactoryBot.create(:email_account, activated: true)
 @sms_account = FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989897',
 otp_verified: true)
 end

 context 'for email account' do
 it 'should create email password' do
 @email_account.update(otp_verified: true)
 post :create_password,
 params: { data: { type: 'email_account',
 attributes: { email: @email_account.email,
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(200)
 end

 it 'not create email because password and confirm password not same' do
 @email_account.update(otp_verified: true)
 post :create_password,
 params: { data: { type: 'email_account',
 attributes: { email: @email_account.email,
 password: 'Test@125',
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not create email because password is blank' do
 @email_account.update(otp_verified: true)
 post :create_password,
 params: { data: { type: 'email_account',
 attributes: { email: @email_account.email,
 password: '',
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not create email because account is not active' do
 @email_account.update(otp_verified: true)
 post :create_password,
 params: { data: { type: 'email_account',
 attributes: { email: 'john@yopmail.com',
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end
 end

 context 'for sms account' do
 it 'should create sms password' do
 @sms_account.update(otp_verified: true)
 post :create_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897',
 country_code: '91',
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(200)
 end

 it 'not create sms because password and confirm password not same' do
 post :create_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897',
 country_code: '91',
 password: 'Test@124',
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not create sms because password is blank' do
 post :create_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897',
 country_code: '91',
 password: '' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not create sms because account is not active' do
 post :create_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989896',
 country_code: '91',
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end
 end
 end

 describe 'reset password' do
 before do
 @email_account = FactoryBot.create(:email_account, activated: true)
 @sms_account = FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989897',
 otp_verified: true)
 end

 context 'for email account' do
 it 'should reset email password' do
 @email_account.update(otp_verified: true)
 post :reset_password,
 params: { data: { type: 'email_account',
 attributes: { email: @email_account.email,
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(200)
 end

 it 'not reset email because password and confirm password not same' do
 @email_account.update(otp_verified: true)
 post :reset_password,
 params: { data: { type: 'email_account',
 attributes: { email: @email_account.email,
 password: 'Test@125',
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not reset email because password is blank' do
 @email_account.update(otp_verified: true)
 post :reset_password,
 params: { data: { type: 'email_account',
 attributes: { email: @email_account.email,
 password: '',
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not reset email because account is not active' do
 @email_account.update(otp_verified: true)
 post :reset_password,
 params: { data: { type: 'email_account',
 attributes: { email: 'john@yopmail.com',
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end
 end

 context 'for sms account' do
 it 'should reset sms password' do
 @sms_account.update(otp_verified: true)
 post :reset_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897',
 country_code: '91',
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(200)
 end

 it 'not reset sms because password and confirm password not same' do
 post :reset_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897',
 country_code: '91',
 password: 'Test@124',
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not reset sms because password is blank' do
 post :reset_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989897',
 country_code: '91',
 password: '' } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end

 it 'not reset sms because account is not active' do
 post :reset_password,
 params: { data: { type: 'sms_account',
 attributes: { full_phone_number: '919898989896',
 country_code: '91',
 password: TEST_PASSWORD,
 confirm_password: TEST_PASSWORD } } }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(422)
 end
 end
 end

 describe '#verify_otp_forgot' do
 context 'when verifying email account' do
 let(:email) { 'test@example.com' }
 let(:otp) { '123456' }

 before do
 allow(AccountBlock::VerifyOtpForgot).to receive(:verify_otp).and_return(account)
 end

 context 'when OTP is verified' do
 let(:account) { instance_double(AccountBlock::Account, email: email) }

 it 'returns success JSON response' do
 post :verify_otp_forgot, params: {
 data: {
 type: 'email_account',
 attributes: { email: email, otp: otp }
 }
 }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(:ok)
 expect(data).to eq({ 'success' => [{ 'email' => 'test@example.com' },
 { 'message' => 'forget otp verified ' }] })
 end
 end

 context 'when OTP is incorrect' do
 let(:account) { 'unequal OTP' }

 it 'returns error JSON response' do
 post :verify_otp_forgot, params: {
 data: {
 type: 'email_account',
 attributes: { email: email, otp: otp }
 }
 }
 expect(response).to have_http_status(:ok)
 data = JSON.parse(response.body)
 expect(data).to eq({ 'errors' => [{ 'message' => 'incorrect otp' }] })
 end
 end

 context 'when email is nil' do
 let(:account) { 'blank' }

 it 'returns error JSON response' do
 post :verify_otp_forgot, params: {
 data: {
 type: 'email_account',
 attributes: { email: nil, otp: otp }
 }
 }
 expect(response).to have_http_status(:ok)
 data = JSON.parse(response.body)
 expect(data).to eq({ 'errors' => [{ 'message' => 'email cannot be blank' }] })
 end
 end

 context 'when email is nil' do
 let(:account) { 'not verified' }

 it 'returns error JSON response' do
 post :verify_otp_forgot, params: {
 data: {
 type: 'email_account',
 attributes: { email: email, otp: otp }
 }
 }
 expect(response).to have_http_status(:ok)
 data = JSON.parse(response.body)
 expect(data).to eq({ 'errors' => [{ 'message' => 'not verified otp' }] })
 end
 end
 end

 context 'when OTP is not correct for sms account' do
 let(:sms_account) do
 FactoryBot.create(:sms_account, activated: true, full_phone_number: '919898989897', otp_verified: true)
 end

 it 'returns success JSON response' do
 post :verify_otp_forgot, params: {
 data: {
 type: 'sms_account',
 attributes: {
 full_phone_number: sms_account.full_phone_number,
 otp: sms_account.otp,
 country_code: sms_account.country_code
 }
 }
 }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(:ok)
 expect(data).to eq({ 'errors' => [{ 'message' => 'incorrect otp' }] })
 end
 end
 end

 describe '#forgot_password' do
 let(:email_account) { FactoryBot.create(:email_account, activated: false) }
 let(:sms_account) { FactoryBot.create(:sms_account, activated: false, full_phone_number: '919898989897') }

 context 'when requesting password reset for an email account' do
 before do
 allow(AccountBlock::EmailValidationMailer).to receive_message_chain(:with, :activation_email, :deliver)
 end

 it 'when account does not exist' do
 post :forgot_password, params: {
 data: {
 type: 'email_account',
 attributes: {
 email: email_account.email
 }
 }
 }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(:unprocessable_entity)
 expect(data).to eq({ 'errors' => [{ 'message' => 'account does not exist! please sign up' }] })
 end

 it 'when email is invalid' do
 post :forgot_password, params: {
 data: {
 type: 'email_account',
 attributes: {
 email: "userexample.com"
 }
 }
 }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(:unprocessable_entity)
 expect(data["errors"]).to eq([{"message"=>"email invalid format!"}])
 end

 it 'when email is blank' do
 post :forgot_password, params: {
 data: {
 type: 'email_account',
 attributes: {
 email: nil
 }
 }
 }
 data = JSON.parse(response.body)
 expect(response).to have_http_status(:unprocessable_entity)
 expect(data).to eq({ 'errors' => [{ 'message' => 'email cannot be blank' }] })
 end
 end

 context 'when requesting forgot password for SMS account' do
 let(:valid_phone_number) { '4567568987' }

 it 'sends SMS for forgot password' do
 allow(AccountBlock::AccountSms).to receive(:forgot_password).and_return(create(:sms_account))

 post :forgot_password, params: {
 data: {
 type: 'sms_account',
 attributes: {
 full_phone_number: sms_account.full_phone_number,
 country_code: '91'
 }
 }
 }

 expect(response).to have_http_status(:created)
 parsed_response = JSON.parse(response.body)
 expect(parsed_response['data']).to be_present
 end

 it 'returns an error for invalid phone number' do
 post :forgot_password, params: {
 data: {
 type: 'sms_account',
 attributes: {
 full_phone_number: '6263847327o38237238749283904820340',
 country_code: '1'
 }
 }
 }

 parsed_response = JSON.parse(response.body)
 expect(parsed_response['errors']).to eq([{"country_code"=>"Please Enter a Valid Number"}])
 end

 it 'returns an error when account is not present' do
 allow(AccountBlock::AccountSms).to receive(:forgot_password).and_return('account not present')

 post :forgot_password, params: {
 data: {
 type: 'sms_account',
 attributes: {
 full_phone_number: '8437883745',
 country_code: '1'
 }
 }
 }

 expect(response).to have_http_status(:unprocessable_entity)
 parsed_response = JSON.parse(response.body)
 expect(parsed_response['errors']).to be_present
 end

 end
 end
end