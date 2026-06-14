const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

dotenv.config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Connect Database
connectDB();

// Route Mounts
app.use('/api/auth', require('./routes/auth'));
app.use('/api/medications', require('./routes/medications'));
app.use('/api/reminders', require('./routes/reminders'));
app.use('/api/dose-logs', require('./routes/doseLogs'));
app.use('/api/family', require('./routes/family'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`MedClock server running on port ${PORT}`));
