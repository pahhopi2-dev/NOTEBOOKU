const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json({ limit: '1mb' }));

const db = admin.firestore();

app.get('/health', (_, res) => {
  res.json({
    ok: true,
    service: 'notebooku-functions',
    time: new Date().toISOString(),
  });
});

app.get('/notes/:userId', async (req, res) => {
  try {
    const collection = userNotes(req.params.userId);
    const snapshot = await collection.orderBy('updatedAt', 'desc').get();
    const notes = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    res.json(notes);
  } catch (error) {
    sendError(res, error);
  }
});

app.post('/notes/:userId', async (req, res) => {
  try {
    const note = sanitizeNote(req.body);
    const docRef = await userNotes(req.params.userId).add({
      ...note,
      syncedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(201).json({ id: docRef.id, ok: true });
  } catch (error) {
    sendError(res, error);
  }
});

app.put('/notes/:userId/:noteId', async (req, res) => {
  try {
    const note = sanitizeNote({ ...req.body, id: req.params.noteId });
    await userNotes(req.params.userId).doc(req.params.noteId).set(
      {
        ...note,
        syncedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    res.json({ id: req.params.noteId, ok: true });
  } catch (error) {
    sendError(res, error);
  }
});

app.delete('/notes/:userId/:noteId', async (req, res) => {
  try {
    await userNotes(req.params.userId).doc(req.params.noteId).delete();
    res.json({ id: req.params.noteId, ok: true });
  } catch (error) {
    sendError(res, error);
  }
});

app.get('/summary/:userId', async (req, res) => {
  try {
    const snapshot = await userNotes(req.params.userId).get();
    let pinned = 0;
    let tasks = 0;

    snapshot.forEach((doc) => {
      const note = doc.data();
      if (note.isPinned === true) pinned += 1;
      if (note.category === 'tasks' || hasChecklist(note.content)) tasks += 1;
    });

    res.json({
      total: snapshot.size,
      pinned,
      tasks,
      generatedAt: new Date().toISOString(),
    });
  } catch (error) {
    sendError(res, error);
  }
});

function userNotes(userId) {
  if (!/^[a-zA-Z0-9_-]{3,80}$/.test(userId || '')) {
    const error = new Error('Invalid userId.');
    error.statusCode = 400;
    throw error;
  }

  return db.collection('users').doc(userId).collection('notes');
}

function sanitizeNote(payload) {
  const now = new Date().toISOString();
  const note = {
    id: stringValue(payload.id),
    title: stringValue(payload.title).slice(0, 180),
    content: stringValue(payload.content).slice(0, 15000),
    category: stringValue(payload.category || 'personal'),
    color: stringValue(payload.color || 'white'),
    createdAt: stringValue(payload.createdAt || now),
    updatedAt: stringValue(payload.updatedAt || now),
    isPinned: payload.isPinned === true,
  };

  if (!note.title && !note.content) {
    const error = new Error('Note must include title or content.');
    error.statusCode = 422;
    throw error;
  }

  return note;
}

function stringValue(value) {
  if (value === undefined || value === null) return '';
  return String(value).trim();
}

function hasChecklist(content) {
  return /\[[ xX]\]/.test(content || '');
}

function sendError(res, error) {
  const status = error.statusCode || 500;
  res.status(status).json({
    ok: false,
    error: error.message || 'Unexpected server error.',
  });
}

exports.api = functions.https.onRequest(app);
