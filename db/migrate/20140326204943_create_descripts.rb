class CreateDescripts < ActiveRecord::Migration
  def change
    create_table :descripts do |t|

      t.timestamps
    end
  end
end
