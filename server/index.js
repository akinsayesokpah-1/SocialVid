// server/index.js
const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const AWS = require('aws-sdk');

const app = express();
app.use(bodyParser.json());

// configure AWS SDK
const s3 = new AWS.S3({ region: process.env.AWS_REGION });
const UPLOAD_BUCKET = process.env.UPLOAD_BUCKET;

// Simple JWT middleware (replace with real auth)
function ensureAuth(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth) return res.status(401).send({ error: 'Missing token' });
  try {
    const payload = jwt.verify(auth.replace('Bearer ', ''), process.env.JWT_SECRET);
    req.user = payload;
    next();
  } catch (err) {
    return res.status(401).send({ error: 'Invalid token' });
  }
}

app.post('/api/v1/signup', async (req, res) => {
  // create user in DB (omitted) and return JWT
  const userId = uuidv4();
  const token = jwt.sign({ sub: userId }, process.env.JWT_SECRET, { expiresIn: '30d' });
  res.json({ id: userId, token });
});

// Request signed URL for direct upload
app.post('/api/v1/videos', ensureAuth, async (req, res) => {
  const { filename, contentType } = req.body;
  if (!filename || !contentType) return res.status(400).send({ error: 'Missing params' });
  const key = `uploads/${req.user.sub}/${Date.now()}_${filename}`;
  const params = {
    Bucket: UPLOAD_BUCKET,
    Key: key,
    ContentType: contentType,
    ACL: 'private'
  };
  const signedUrl = s3.getSignedUrl('putObject', { ...params, Expires: 60 * 10 });
  // create video row with processing_status = 'uploaded' (omitted DB code)
  res.json({ uploadUrl: signedUrl, objectKey: key });
});

// Callback when client finishes upload
app.post('/api/v1/videos/complete', ensureAuth, async (req, res) => {
  const { objectKey, title, description } = req.body;
  // validate, insert DB record, and publish event to queue for transcoding (omitted)
  res.json({ ok: true });
});

app.listen(process.env.PORT || 8080, () => console.log('Server started'));
