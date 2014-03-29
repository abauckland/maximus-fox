class CreatePerformkeys < ActiveRecord::Migration
  def change
    create_table :performkeys do |t|

      t.timestamps
    end
  end
end
