class SiteDemoTables < ActiveRecord::Migration
  def self.up


    create_table :site_demo_domains do |t|
      t.integer :domain_index
      t.integer :domain_id
      t.string :name
      t.boolean :active, :default => false
      t.datetime :activated_at
      t.datetime :expires_at 
      t.integer :site_demo_template_id
      t.string :login_email
      t.string :login_password
      t.timestamps
    end


    create_table :site_demo_log_entries do |t|
      t.string :name
      t.integer :site_demo_domain_id
      t.string :login_email
      t.string :login_password
      t.integer :site_demo_template_id
      t.timestamps
    end

    create_table :site_demo_templates do |t|
      t.string :name
      t.string :directory
      t.text :description
      t.integer :weight
      t.boolean :protected_template, :default => false
      t.timestamps
    end

  end

  def self.down
    drop_table :site_demo_domains
    drop_table :site_demo_log_entries
    drop_table :site_demo_templates
  end
end
