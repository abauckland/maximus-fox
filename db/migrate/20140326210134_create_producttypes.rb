class CreateProducttypes < ActiveRecord::Migration
  def change
    create_table :producttypes do |t|

      t.timestamps
    end
  end
end
