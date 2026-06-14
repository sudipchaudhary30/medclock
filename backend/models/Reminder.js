const mongoose = require('mongoose');

const ReminderSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  medicationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Medication', required: true },
  scheduledTime: { type: String, required: true },
  days: { type: [String], default: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] },
  maxSnoozeCount: { type: Number, default: 2 },
  currentSnoozeCount: { type: Number, default: 0 },
  status: { type: String, enum: ['active', 'snoozed', 'fired', 'dismissed'], default: 'active' },
  lateCount: { type: Number, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model('Reminder', ReminderSchema);
