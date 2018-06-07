class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :name
      t.integer :year
      t.integer :manufacturer_id
    end
  end
end
