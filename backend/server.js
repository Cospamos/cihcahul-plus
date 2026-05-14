const express = require('express');
const path = require('path');
const livereload = require('livereload');
const connectLivereload = require('connect-livereload');
const chokidar = require('chokidar');

const app = express();

app.use(connectLivereload());

app.use(express.static(path.join(__dirname, '../frontend')));

app.use((req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});


const liveReloadServer = livereload.createServer({
  host: '192.168.100.25',
  port: 35729
});
liveReloadServer.watch(path.join(__dirname, '../frontend'));

liveReloadServer.server.once("connection", () => {
  console.log("🔁 LiveReload client connected.");
});

const frontendPath = path.join(__dirname, '../frontend');

const watcher = chokidar.watch(frontendPath, {
  ignoreInitial: true,
  usePolling: true,
  interval: 100,
});

watcher.on('change', () => {
  liveReloadServer.refresh('/');
});


const PORT = 3000;
app.listen(PORT, "0.0.0.0",() => {
  console.log(`Server running at http://192.168.100.25:${PORT}`);
});
