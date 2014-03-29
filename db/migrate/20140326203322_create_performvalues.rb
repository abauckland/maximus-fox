class CreatePerformvalues < ActiveRecord::Migration
  def change
    create_table :performvalues do |t|

      t.timestamps
    end
  end
end
