const express = require('express');
const FamilyGroup = require('../models/FamilyGroup');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/', auth, async (req, res) => {
  try {
    const group = await FamilyGroup.findOne({ createdBy: req.user.id });
    res.json(group);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

router.post('/members', auth, async (req, res) => {
  const { userId, name, role, color } = req.body;
  try {
    let group = await FamilyGroup.findOne({ createdBy: req.user.id });
    if (!group) {
      group = new FamilyGroup({
        name: `${req.user.id}'s Family`,
        createdBy: req.user.id,
        members: []
      });
    }

    const member = { userId, name, role, color };
    group.members.push(member);
    await group.save();

    // Return the newly created member details
    res.status(201).json(group.members[group.members.length - 1]);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

module.exports = router;
