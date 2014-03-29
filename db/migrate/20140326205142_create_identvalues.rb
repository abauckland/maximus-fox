class CreateIdentvalues < ActiveRecord::Migration
  def change
    create_table :identvalues do |t|

      t.timestamps
    end
  end
end
