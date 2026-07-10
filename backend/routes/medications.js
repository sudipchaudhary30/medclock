const express = require('express');
const Medication = require('../models/Medication');
const auth = require('../middleware/auth');

const router = express.Router();

// Get user medications
router.get('/', auth, async (req, res) => {
  try {
    const meds = await Medication.find({ userId: req.user.id });
    res.json(meds);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

// Add medication
router.post('/', auth, async (req, res) => {
  const { name, dosage, form, instructions, totalSupply, refillThreshold, pillPhotoUrl } = req.body;
  try {
    const newMed = new Medication({
      userId: req.user.id,
      name,
      dosage,
      form,
      instructions,
      totalSupply,
      currentSupply: totalSupply,
      refillThreshold,
      pillPhotoUrl
    });

    const med = await newMed.save();
    res.status(201).json(med);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

// Update medication
router.put('/:id', auth, async (req, res) => {
  const { id } = req.params;
  try {
    const med = await Medication.findOneAndUpdate({ _id: id, userId: req.user.id }, req.body, { new: true });
    if (!med) return res.status(404).send('Not found');
    res.json(med);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

// Delete medication
router.delete('/:id', auth, async (req, res) => {
  const { id } = req.params;
  try {
    const med = await Medication.findOneAndDelete({ _id: id, userId: req.user.id });
    if (!med) return res.status(404).send('Not found');
    res.json({ success: true });
  } catch (err) {
    res.status(500).send('Server error');
  }
});

module.exports = router;
