class AddScResourceIdToScCanvases < ActiveRecord::Migration
  def change
    add_column :sc_canvases, :sc_resource_id, :string
  end
end
