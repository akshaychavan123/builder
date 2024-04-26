in lib/tasks/file_name.rake.rb

    for creating any rake data we have to provise namespace and task so after that rake taskcan be run with below command
        rails namespace:tasks_name

        give :enviornment in front of task 

        examples: ========================11111=====================================

        require_relative '../../config/environment'

namespace :deploy do
  desc 'creating bank details'
  task :bank_details do
n = 10 

n.times do
    BankDetail.create(account_name: "Bank of xxxxxxxxx#{n}", account_number: "456456456#{n}", user_id: 27)
    n = n -1 
    end
    puts "bank details created successfully"
  end
end


rails deploy:bank_details
==================22222222========================================================

namespace :db do
    desc "Sign_up users in production database"
    task sign_up_users: :environment do
      if Rails.env.production?
        puts "Starting sign_up user in production environment..."
        users = [
          { email: 'example1@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'example2@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'saurabh.singh@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'tanushree@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'arshad.qureshi@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'ashok.kumar@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'pradeep.kumar@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'sunil.saini@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'piyush.gupta@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'naveen.sharma@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'priya.jain@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'priyal.jain@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'ayushi.khandelwal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'example14@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'Prashant.joshi@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'yash.gurjar@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'kiran.kanwar@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'mitali.khandelwal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'kapil.sharma@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'vaishali.verma@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'vishal.jaiswal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'parul.gupta@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'arvind.khandal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'kushagra.choudhary@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'aditi.gupta@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'charchit.khandelwal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'dharmendra.garg@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'kamini.kumawat@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'prakash.chand@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'sneha.singhal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'sonali.gupta@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'pknnirban@gmail.com', password: 'password', confirm_password: 'password'},
          { email: 'himanshu.gupta@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'navdeep.shekhawat@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'ronit.bhandari@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'sahil.khan@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'himanshu.agarwal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'ashish.jain@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'piyush.manglani@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'example40@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'rajendra.prajapat@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'ishvar.jangid@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'khushboo.sukhani@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'gashish079@gmail.com', password: 'password', confirm_password: 'password'},
          { email: 'hemr843263@gmail.com', password: 'password', confirm_password: 'password'},
          { email: 'harish.parashar@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'example47@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'karanbairwaa@gmail.com', password: 'password', confirm_password: 'password'},
          { email: 'kritika.paliwal@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'ashutosh.sharma@deeporion.com', password: 'password', confirm_password: 'password'},
          { email: 'sainvikash1507@gmail.com', password: 'password', confirm_password: 'password'},
          { email: 'garima.kumawat@deeporion.com', password: 'password', confirm_password: 'password'}
          
          
        ]
  
        users.each do |user_params|
          user = User.new(
            email: user_params[:email],
            password: user_params[:password],
            password_confirmation: user_params[:confirm_password]
          )
          if user.save
            puts "User #{user.email} created successfully."
          else
            puts "Error creating user #{user.email}: #{user.errors.full_messages.join(', ')}"
          end
        end
  
        puts "Users population complete."
      else
        puts "This task is intended for the production environment."
      end
    end
    
    desc "Assign admin role to user in production database"
      task assign_admin_roles: :environment do
        if Rails.env.production?
          admin_emails = [
            'kushagra.choudhary@deeporion.com'
            # Add more emails as needed
          ]
          
          admin_emails.each do |email|
            user = User.find_by(email: email)
            if user
             
              user.add_role(:admin)
              puts "User #{user.email} assigned as admin."
            else
              puts "User with email #{email} not found."
            end
          end
        else
          puts "This task is intended for the production environment."
        end
      end
end
  


command == 
rails db:sign_up_users