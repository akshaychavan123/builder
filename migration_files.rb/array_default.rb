class AddListOfProductToCompanyOverviews < ActiveRecord::Migration[6.0]
    def change
      add_column :company_overviews, :list_of_product, :string, array: true, default: []
    end
  end
  

in params  ad at last 
    params.require(:list_of_product).permit(:name, :age, :abc, list_of_product:[])