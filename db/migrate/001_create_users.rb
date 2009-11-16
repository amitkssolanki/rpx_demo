class CreateUsers < ActiveRecord::Migration
  def self.up
    execute "BEGIN"
    create_table :users do |t|
      t.column "name", :string
      t.column "pass_hash", :string
    end
    add_index :users, :name, :unique => true
    execute "COMMIT"
  end

  def self.down
    execute "BEGIN"
    drop_table :users
    execute "COMMIT"
  end
end
