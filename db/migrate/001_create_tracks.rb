migration 1, :create_tracks do
  up do
    create_table :tracks do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :tracks
  end
end
