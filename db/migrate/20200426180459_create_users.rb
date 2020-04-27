class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :slack_id
      t.string :github_id
      t.boolean :enabled_2fa, default: false
      t.string :encrypted_2fa_secret
      t.string :last_2fa_at
      t.timestamps null: false
    end
  end
end
