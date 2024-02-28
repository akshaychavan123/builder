class RemoveQuestionAndAnswerFromPrivateInformations < ActiveRecord::Migration[6.0]
    def change
      add_column :private_informations, :competitors, :string, array: true, default: []
  
      reversible do |dir|
        dir.up do
          remove_column :private_informations, :question, :string
          remove_column :private_informations, :answer, :string
        end
  
        dir.down do
          add_column :private_informations, :question, :string
          add_column :private_informations, :answer, :string
        end
      end
    end
  end
  