class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nick
      t.string :twitter
      t.string :github
    end
  end
end
