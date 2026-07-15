const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['patient', 'caregiver'], default: 'patient' },
  phone: { type: String },
  photoBase64: { type: String },
  linkedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  familyGroupId: { type: mongoose.Schema.Types.ObjectId, ref: 'FamilyGroup' },
  settings: {
    fontSize: { type: Number, default: 16 },
    quietHoursStart: { type: String, default: '23:00' },
    quietHoursEnd: { type: String, default: '07:00' },
    reminderSound: { type: String, default: '' },
    reminderVolume: { type: Number, default: 1.0 },
    isDarkMode: { type: Boolean, default: false }
  }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
