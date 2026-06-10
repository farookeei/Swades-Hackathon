const Database = require('better-sqlite3');
const path = require('path');

// Initialize the database file
const db = new Database(path.join(__dirname, '../database.db'));

// Enable foreign keys
db.pragma('foreign_keys = ON');

// Create the tables
db.exec(`
  CREATE TABLE IF NOT EXISTS venues (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    capacity INTEGER NOT NULL
  );

  CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    venue_id INTEGER NOT NULL,
    user_id TEXT NOT NULL,
    date TEXT NOT NULL,          -- Format: YYYY-MM-DD
    slot TEXT NOT NULL,          -- Format: '06:00', '07:00', etc.
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(venue_id) REFERENCES venues(id) ON DELETE CASCADE,
    UNIQUE(venue_id, date, slot) -- Crucial unique constraint to prevent double-booking
  );
`);

// Seed default venues if the table is empty
const row = db.prepare('SELECT COUNT(*) AS count FROM venues').get();
if (row.count === 0) {
  const insertVenue = db.prepare('INSERT INTO venues (name, location, capacity) VALUES (?, ?, ?)');
  
  const seedVenues = [
    { name: 'Arena Futsal Court', location: 'Zone A, Level 1', capacity: 10 },
    { name: 'Grand Badminton Hall', location: 'Zone B, Level 2', capacity: 4 },
    { name: 'Sky Tennis Court', location: 'Rooftop, Block C', capacity: 4 },
    { name: 'Championship Basketball Court', location: 'Zone A, Level 2', capacity: 15 },
    { name: 'Premium Squash Court', location: 'Block B, Basement 1', capacity: 2 }
  ];

  const transaction = db.transaction((venues) => {
    for (const venue of venues) {
      insertVenue.run(venue.name, venue.location, venue.capacity);
    }
  });

  transaction(seedVenues);
  console.log('Database initialized and seeded with venues.');
} else {
  console.log('Database already initialized.');
}

module.exports = db;
