const mongoose = require('mongoose');

const MedicationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  dosage: { type: String, required: true },
  form: { type: String, default: 'tablet' },
  instructions: { type: String },
  totalSupply: { type: Number, default: 30 },
  currentSupply: { type: Number, default: 30 },
  refillThreshold: { type: Number, default: 7 },
  pillPhotoUrl: { type: String },
  similarMedications: [{ type: String }]
}, { timestamps: true });

module.exports = mongoose.model('Medication', MedicationSchema);
