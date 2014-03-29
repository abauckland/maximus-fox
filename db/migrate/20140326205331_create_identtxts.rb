class CreateIdenttxts < ActiveRecord::Migration
  def change
    create_table :identtxts do |t|

      t.timestamps
    end
  end
end
