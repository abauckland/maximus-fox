class CreateSponsors < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
      t.int :company_id
      t.int :subsection_id

      t.timestamps
    end
  end
end
