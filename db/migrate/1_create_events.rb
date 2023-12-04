Sequel.migration do
  change do
    create_table :events do
      primary_key :id

      integer :year, null: false

      datetime :created_at
      datetime :updated_at

      index :year
    end
  end
end
