class CreatePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :plans do |t|
      t.belongs_to :user
      t.string :departure
      t.date :date_of_departure
      t.string :arrival
      t.date :date_of_return
      t.integer :adults
      t.integer :infants
      t.string :flight_class

      t.timestamps
    end
  end
end
