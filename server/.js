const express = require("express");
const app = express();
const port = 3000;

function log() {
  let stream = [];

  function emit(message) {
    stream
      .push(message);
    return;
  }

  function read(position) {
    return stream
      .at(position);
  }
}

function handle(expression, callback) {
    if (!expression) {
      log()
        .emit("Handling Expection @ handle");
      callback();
    }
    log()
      .emit("No error");
    return;
}

function consumer() {
  
}

// Define a sample endpoint
app.get("/api/hello", (req, res) => {
  console.log("Hello");
  res.json({ message: "Hello, API!" });
});

// Start the server
app.listen(port, () => {
  console.log(`Server is listening at http://localhost:${port}`);
  handle(port === "", () => {

  })
});
