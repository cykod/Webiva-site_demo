class AddImage < ActiveRecord::Migration
  def self.up
    add_column :site_demo_templates,:image_id, :integer
  end

  def self.down
    remove_column :site_demo_templates, :image_id
  end
end
