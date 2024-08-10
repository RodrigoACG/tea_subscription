class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :title
      t.decimal :price
      t.string :frequency
      t.references :customer, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
