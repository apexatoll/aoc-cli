Sequel.migration do
  change do
    create_table :puzzles do
      primary_key :id

      foreign_key :event_id, :events, null: false

      integer :day, null: false

      text :content, null: false
      text :input, null: false

      datetime :created_at
      datetime :updated_at
      datetime :part_one_completed_at
      datetime :part_two_completed_at

      index :event_id
    end
  end
end
