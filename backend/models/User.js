const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['patient', 'caregiver'], default: 'patient' },
  phone: { type: String },
  linkedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  settings: {
    fontSize: { type: Number, default: 16 },
    quietHoursStart: { type: String, default: '23:00' },
    quietHoursEnd: { type: String, default: '07:00' }
  }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
