Sequel.migration do
  change do
    create_table :locations do
      primary_key :id

      string :path, null: false

      integer :resource_id, null: false
      string :resource_type, null: false

      datetime :created_at
      datetime :updated_at

      index %i[path resource_id resource_type]
    end
  end
end
