const mongoose = require('mongoose');

const FamilyGroupSchema = new mongoose.Schema({
  name: { type: String, required: true },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  members: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    name: { type: String, required: true },
    color: { type: String, default: '#2D7DD2' },
    role: { type: String, enum: ['patient', 'caregiver'], default: 'patient' }
  }]
}, { timestamps: true });

module.exports = mongoose.model('FamilyGroup', FamilyGroupSchema);
