+++ b/template-app/app/admin/chatbot.rb
@@ -0,0 +1,7 @@
+ActiveAdmin.register BxBlockChatbot5::ChatBot, as:'ChatBot' do
+
+    permit_params :user_input, :bot_response
+  
+    actions :all
+  end  
+  
\ No newline at end of file
diff --git a/template-app/app/controllers/bx_block_chatbot5/chat_bots_controller.rb b/template-app/app/controllers/bx_block_chatbot5/chat_bots_controller.rb
new file mode 100644
index 00000000..d892871b
--- /dev/null
+++ b/template-app/app/controllers/bx_block_chatbot5/chat_bots_controller.rb
@@ -0,0 +1,27 @@
+module BxBlockChatbot5
+    class ChatBotsController < ApplicationController
+        # before_action :current_user
+
+        def chat_bot_interaction
+            user_input = params[:user_input]
+            bot_response = ChatBot.find_by(user_input: user_input)
+            if user_input.blank?
+                render json: { success: "Please provide query input" }, status: :unprocessable_entity
+            elsif bot_response.present?
+                render json: { success: bot_response.bot_response }
+            else
+                link = "https://example.com"  
+                response_with_link = "Sorry we don't have an answer for the query input. Please follow this #{link} for more information."
+            
+                new_chatbot = ChatBot.create(user_input: user_input, bot_response: response_with_link)
+                render json: { success: new_chatbot.bot_response }
+            end
+        end
+
+        private
+        def chatbot_params
+            params.require(:chatbot).permit(:user_input, :bot_response)
+        end
+      
+    end
+end
\ No newline at end of file
diff --git a/template-app/app/models/bx_block_chatbot5/chat_bot.rb b/template-app/app/models/bx_block_chatbot5/chat_bot.rb
new file mode 100644
index 00000000..7a189773
--- /dev/null
+++ b/template-app/app/models/bx_block_chatbot5/chat_bot.rb
@@ -0,0 +1,8 @@
+
+module BxBlockChatbot5
+    class ChatBot < BxBlockChatbot5::ApplicationRecord
+      self.table_name = :bx_block_chatbot5_chat_bots
+      validates :user_input, presence: true, uniqueness: true
+      validates :bot_response, presence: true, uniqueness: true
+    end
+end
\ No newline at end of file
diff --git a/template-app/config/routes.rb b/template-app/config/routes.rb
index 8f8383c6..8c6efb0b 100644
--- a/template-app/config/routes.rb
+++ b/template-app/config/routes.rb
@@ -54,4 +54,12 @@ Rails.application.routes.draw do
     resources :faqs
     resources :contacts 
   end 
+
+  namespace :bx_block_chatbot5 do
+    resources :chat_bots do
+      collection do
+        post 'chat_bot_interaction'
+      end
+    end
+  end
 end
diff --git a/template-app/db/migrate/20231120102227_create_bx_block_chatbot5_chat_bots.rb b/template-app/db/migrate/20231120102227_create_bx_block_chatbot5_chat_bots.rb
new file mode 100644
index 00000000..60b09751
--- /dev/null
+++ b/template-app/db/migrate/20231120102227_create_bx_block_chatbot5_chat_bots.rb
@@ -0,0 +1,9 @@
+class CreateBxBlockChatbot5ChatBots < ActiveRecord::Migration[6.0]
+  def change
+    create_table :bx_block_chatbot5_chat_bots do |t|
+      t.string :user_input
+      t.string :bot_response
+      t.timestamps
+    end
+  end
+end
diff --git a/template-app/spec/factories/bx_block_chatbot5/chat_bots.rb b/template-app/spec/factories/bx_block_chatbot5/chat_bots.rb
new file mode 100644
index 00000000..6dc5cc34
--- /dev/null
+++ b/template-app/spec/factories/bx_block_chatbot5/chat_bots.rb
@@ -0,0 +1,6 @@
+FactoryBot.define do
+  factory :chat_bot, class: 'BxBlockChatbot5::ChatBot' do
+    sequence(:user_input) { |n| "UserInput#{n}" }
+    sequence(:bot_response) { |n| "BotResponse#{n}" }
+  end
+end
\ No newline at end of file
diff --git a/template-app/spec/models/bx_block_chatbot5/chat_bot_spec.rb b/template-app/spec/models/bx_block_chatbot5/chat_bot_spec.rb
new file mode 100644
index 00000000..6610ef03
--- /dev/null
+++ b/template-app/spec/models/bx_block_chatbot5/chat_bot_spec.rb
@@ -0,0 +1,22 @@
+require 'rails_helper'
+
+module BxBlockChatbot5
+  RSpec.describe ChatBot, type: :model do
+    describe 'validations' do
+      it { should validate_presence_of(:user_input) }
+      it { should validate_uniqueness_of(:user_input) }
+
+      it { should validate_presence_of(:bot_response) }
+      it { should validate_uniqueness_of(:bot_response).case_insensitive }
+    end
+
+    describe 'database columns' do
+      it { should have_db_column(:user_input).of_type(:string) }
+      it { should have_db_column(:bot_response).of_type(:string) }
+    end
+
+    it 'has a valid factory' do
+      expect(create(:chat_bot)).to be_valid
+    end
+  end
+end
\ No newline at end of file
