const express = require('express');
const DoseLog = require('../models/DoseLog');
const Medication = require('../models/Medication');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/', auth, async (req, res) => {
  try {
    const logs = await DoseLog.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json(logs);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

router.post('/', auth, async (req, res) => {
  const { medicationId, reminderId, status, confirmedAt, scheduledAt, photoUrl, missedReason, missedNote } = req.body;
  try {
    const newLog = new DoseLog({
      userId: req.user.id,
      medicationId,
      reminderId,
      status,
      confirmedAt,
      scheduledAt,
      photoUrl,
      missedReason,
      missedNote,
      confirmedBy: req.user.id
    });

    const log = await newLog.save();

    // Deduct stock if status is 'taken'
    if (status === 'taken') {
      await Medication.findByIdAndUpdate(medicationId, {
        $inc: { currentSupply: -1 }
      });
    }

    res.status(201).json(log);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

module.exports = router;
