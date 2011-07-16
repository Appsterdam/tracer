migration 2, :create_races do
  up do
    create_table :races do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :races
  end
end
