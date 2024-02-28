class RemoveReferenceCategoryFromSummarry < ActiveRecord::Migration[6.0]
    def up
      add_column :summarries, :sub_category_id, :bigint
      remove_reference :summarries, :category, foreign_key: true
  
      add_column :accounts, :is_member, :boolean, default: false
      add_column :accounts, :total_no_of_access, :integer, default: 0
      add_column :accounts, :remaining_access, :integer, default: 0
  
    end
  
    def down
      remove_column :accounts, :is_member, :boolean, default: false
      remove_column :accounts, :total_no_of_access, :integer, default: 0
      remove_column :accounts, :remaining_access, :integer, default: 0
  
      remove_column :summarries, :sub_category_id, :bigint
      add_reference :summarries, :category, foreign_key: true
    end
  
  end
  

  remove_reference :summarries, :category, foreign_key: true
                    table_name , :model_name