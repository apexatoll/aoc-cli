Sequel.migration do
  change do
    alter_table :puzzles do
      drop_column :part_one_completed_at
      drop_column :part_two_completed_at
    end
  end
end
