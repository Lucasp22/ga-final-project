class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
    t.text :password_digest
     t.text :email
      t.timestamps
    end
  end
end