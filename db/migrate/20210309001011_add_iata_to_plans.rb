class AddIataToPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :IATA_to, :string
    add_column :plans, :IATA_from, :string
  end
end
