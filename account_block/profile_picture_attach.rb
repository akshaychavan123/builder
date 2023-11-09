--- a/template-app/app/controllers/account_block/accounts_controller.rb
+++ b/template-app/app/controllers/account_block/accounts_controller.rb
@@ -149,8 +149,25 @@ module AccountBlock
       end
     end
 
+    def upload_profile_picture
+      account = Account.find_by(id: params[:id])
+      if account.present?
+        if account.update(profile_picture: params["profile_picture"])
+          return render json: AccountSerializer.new(account, serialization_options).serializable_hash, status: :ok 
+        else
+          render json: {errors: "profile_picture is not present"}, status: :unprocessable_entity
+        end
+      else
+        render json: {message: "PLEASE ENTER VALID ID"},status: 404
+      end
+    end
private
 
+    def serialization_options
+      { params: { host: request.protocol + request.host_with_port } }
+    end
+

+++ b/template-app/app/models/account_block/account.rb
@@ -2,6 +2,7 @@ module AccountBlock
   class Account < AccountBlock::ApplicationRecord
     ActiveSupport.run_load_hooks(:account, self)
     self.table_name = :accounts
+    has_one_attached :profile_picture


module AccountBlock
    class AccountSerializer < BuilderBase::BaseSerializer
 -    attributes(:activated, :country_code, :email, :first_name, :full_phone_number, :last_name, :phone_number, :type, :created_at, :updated_at, :device_id, :unique_auth_id)
 +    attributes(:activated, :country_code, :email, :first_name, :full_phone_number, :last_name, :phone_number, :type, :created_at, :updated_at, :device_id, :unique_auth_id, :profile_picture)
  
      attribute :country_code do |object|
        country_code_for object
 @@ -10,6 +10,21 @@ module AccountBlock
        phone_number_for object
      end
  
 +    attribute :profile_picture do |object|
 +      object.profile_picture.url
 +    end
 +
 +    attribute :profile_picture do |object, params|
 +      host = params[:host] rescue ""
 +      if object&.profile_picture.attached?
 +        url = if Rails.env.development? || Rails.env.test? || false
 +         host + Rails.application.routes.url_helpers.rails_blob_url(object&.profile_picture, only_path: true )
 +        else
 +          object.profile_picture.service_url.split("?").first
 +        end
 +      end
 +    end
 +

    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
+  namespace :account_block do
    +         resource :accounts do 
    +               collection do 
    +                       put :upload_profile_picture
    +               end
    +         end
    +       end
     end
    
 


