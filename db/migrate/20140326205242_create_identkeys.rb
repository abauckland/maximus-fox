class CreateIdentkeys < ActiveRecord::Migration
  def change
    create_table :identkeys do |t|

      t.timestamps
    end
  end
end
