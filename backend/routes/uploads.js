const express = require('express');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// POST /api/uploads - upload a single file under field name `file`
router.post('/', auth, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).send('No file uploaded');
    const fileName = req.file.filename;
    const url = `${req.protocol}://${req.get('host')}/uploads/${fileName}`;
    return res.json({ url });
  } catch (err) {
    return res.status(500).send('Upload failed');
  }
});

module.exports = router;
