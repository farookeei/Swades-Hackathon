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

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
