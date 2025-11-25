const express = require('express');
const app = express();

app.get('/hello', (req, res) => {
    res.json({ message: 'Hello, World!' });
});

app.get('/user/:id', (req, res) => {
    res.json({ id: req.params.id, name: `User ${req.params.id}` });
});

app.listen(3002, () => {
    console.log('Express server running on port 3002');
});
