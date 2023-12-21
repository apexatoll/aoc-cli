Sequel.migration do
  change do
    create_table :puzzle_dir_sync_logs do
      primary_key :id

      foreign_key :puzzle_id, :puzzles, null: false
      foreign_key :location_id, :locations, null: false

      integer :puzzle_status, null: false
      integer :input_status, null: false

      datetime :created_at
      datetime :updated_at

      index %i[puzzle_id location_id]
    end
  end
end
