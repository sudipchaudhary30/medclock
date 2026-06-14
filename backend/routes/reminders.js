const express = require('express');
const Reminder = require('../models/Reminder');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/', auth, async (req, res) => {
  try {
    const reminders = await Reminder.find({ userId: req.user.id });
    res.json(reminders);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

router.post('/', auth, async (req, res) => {
  const { medicationId, scheduledTime, days } = req.body;
  try {
    const newReminder = new Reminder({
      userId: req.user.id,
      medicationId,
      scheduledTime,
      days
    });
    const reminder = await newReminder.save();
    res.status(201).json(reminder);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

router.post('/:id/snooze', auth, async (req, res) => {
  try {
    const reminder = await Reminder.findById(req.params.id);
    if (!reminder) return res.status(404).json({ msg: 'Reminder not found' });

    if (reminder.currentSnoozeCount >= reminder.maxSnoozeCount) {
      return res.status(400).json({ msg: 'Max snooze count reached' });
    }

    reminder.currentSnoozeCount += 1;
    reminder.status = 'snoozed';
    await reminder.save();
    res.json(reminder);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

module.exports = router;
