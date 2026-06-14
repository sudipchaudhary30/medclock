const mongoose = require('mongoose');

const DoseLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  medicationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Medication', required: true },
  reminderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Reminder' },
  status: { type: String, enum: ['taken', 'missed', 'skipped'], required: true },
  confirmedAt: { type: Date },
  scheduledAt: { type: Date, required: true },
  photoUrl: { type: String },
  missedReason: { type: String, enum: ['forgot', 'asleep', 'side_effect', 'other'] },
  missedNote: { type: String },
  confirmedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}, { timestamps: true });

module.exports = mongoose.model('DoseLog', DoseLogSchema);
