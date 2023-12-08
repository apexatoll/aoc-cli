Sequel.migration do
  change do
    create_table :attempts do
      primary_key :id

      foreign_key :puzzle_id, :puzzles, null: false

      integer :level, null: false
      text :answer, null: false

      integer :status, null: false
      integer :hint
      integer :wait_time

      datetime :created_at
      datetime :updated_at
    end
  end
end
