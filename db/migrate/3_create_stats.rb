Sequel.migration do
  change do
    create_table :stats do
      primary_key :id

      foreign_key :event_id, :events, null: false

      1.upto(25) do |i|
        integer :"day_#{i}", null: false, default: 0
      end

      datetime :created_at
      datetime :updated_at
      datetime :completed_at

      index :event_id
    end
  end
end
