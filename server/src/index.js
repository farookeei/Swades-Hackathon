const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// GET /venues - Fetch list of all seeded venues
app.get('/venues', (req, res) => {
  try {
    const venues = db.prepare('SELECT * FROM venues').all();
    res.json(venues);
  } catch (error) {
    console.error('Error fetching venues:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /venues/:id/slots - Dynamic slot generation for a specific date
app.get('/venues/:id/slots', (req, res) => {
  const venueId = parseInt(req.params.id, 10);
  const { date } = req.query; // Expects YYYY-MM-DD

  if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    return res.status(400).json({ error: 'Valid date parameter (YYYY-MM-DD) is required' });
  }

  try {
    // 1. Verify venue exists
    const venue = db.prepare('SELECT * FROM venues WHERE id = ?').get(venueId);
    if (!venue) {
      return res.status(404).json({ error: 'Venue not found' });
    }

    // 2. Fetch existing bookings for this venue on the given date
    const bookings = db.prepare('SELECT slot, user_id FROM bookings WHERE venue_id = ? AND date = ?').all(venueId, date);
    
    // Map existing bookings for fast lookup
    const bookedSlotsMap = {};
    bookings.forEach(b => {
      bookedSlotsMap[b.slot] = b.user_id;
    });

    // 3. Generate 17 hourly slots from 6 AM (06:00) to 10 PM (22:00)
    const hours = [
      '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
      '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00',
      '20:00', '21:00', '22:00'
    ];

    const slots = hours.map(time => {
      const bookedBy = bookedSlotsMap[time];
      return {
        time,
        isAvailable: !bookedBy,
        bookedBy: bookedBy || null
      };
    });

    res.json({
      venue,
      date,
      slots
    });

  } catch (error) {
    console.error('Error generating slots:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /bookings - Fetch active bookings for a user (includes venue details)
app.get('/bookings', (req, res) => {
  const { user_id } = req.query;
  if (!user_id) {
    return res.status(400).json({ error: 'user_id query parameter is required' });
  }

  try {
    const query = `
      SELECT b.id, b.venue_id, b.user_id, b.date, b.slot, b.created_at,
             v.name AS venue_name, v.location AS venue_location
      FROM bookings b
      JOIN venues v ON b.venue_id = v.id
      WHERE b.user_id = ?
      ORDER BY b.date ASC, b.slot ASC
    `;
    const userBookings = db.prepare(query).all(user_id);
    res.json(userBookings);
  } catch (error) {
    console.error('Error fetching bookings:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /bookings - Create a booking (with 409 Concurrency Protection)
app.post('/bookings', (req, res) => {
  const { venue_id, user_id, date, slot } = req.body;

  // Validation
  if (!venue_id || !user_id || !date || !slot) {
    return res.status(400).json({ error: 'venue_id, user_id, date, and slot are required' });
  }

  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    return res.status(400).json({ error: 'Date must be in YYYY-MM-DD format' });
  }

  // Validate slot hour format
  const validHours = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00',
    '20:00', '21:00', '22:00'
  ];
  if (!validHours.includes(slot)) {
    return res.status(400).json({ error: 'Invalid slot time. Operating hours are 6 AM to 10 PM.' });
  }

  try {
    // 1. Verify venue exists
    const venue = db.prepare('SELECT * FROM venues WHERE id = ?').get(venue_id);
    if (!venue) {
      return res.status(404).json({ error: 'Venue does not exist' });
    }

    // 2. Perform booking insertion
    const insertStmt = db.prepare(`
      INSERT INTO bookings (venue_id, user_id, date, slot)
      VALUES (?, ?, ?, ?)
    `);
    const info = insertStmt.run(venue_id, user_id, date, slot);

    // 3. Fetch newly created booking to return to client
    const newBooking = db.prepare(`
      SELECT b.id, b.venue_id, b.user_id, b.date, b.slot, b.created_at,
             v.name AS venue_name, v.location AS venue_location
      FROM bookings b
      JOIN venues v ON b.venue_id = v.id
      WHERE b.id = ?
    `).get(info.lastInsertRowid);

    res.status(201).json(newBooking);

  } catch (error) {
    // 4. Detect unique constraint violation (Double-booking conflict)
    if (error.code === 'SQLITE_CONSTRAINT_UNIQUE' || error.message.includes('UNIQUE constraint failed')) {
      console.warn(`Booking conflict: venue ${venue_id} is already booked at ${slot} on ${date}`);
      return res.status(409).json({ error: 'This time slot is already booked. Please choose another one.' });
    }

    console.error('Error creating booking:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /bookings/:id - Cancel/remove a booking
app.delete('/bookings/:id', (req, res) => {
  const bookingId = parseInt(req.params.id, 10);

  try {
    const deleteStmt = db.prepare('DELETE FROM bookings WHERE id = ?');
    const info = deleteStmt.run(bookingId);

    if (info.changes === 0) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json({ message: 'Booking canceled successfully' });
  } catch (error) {
    console.error('Error canceling booking:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
