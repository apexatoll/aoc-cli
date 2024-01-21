Sequel.migration do
  change do
    create_table :progresses do
      primary_key :id

      foreign_key :puzzle_id, :puzzles, null: false

      integer :level, null: false

      datetime :started_at, null: false
      datetime :completed_at

      datetime :created_at
      datetime :updated_at
    end
  end
end
