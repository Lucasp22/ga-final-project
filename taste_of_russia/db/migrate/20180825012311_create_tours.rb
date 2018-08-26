class CreateTours < ActiveRecord::Migration[5.2]
  def change
    create_table :tours do |t|
      t.string :title
      t.string :description
      t.integer :price
      t.string :image_url

      t.timestamps
    end
  end
end
