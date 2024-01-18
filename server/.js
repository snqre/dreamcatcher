const express = require("express");
const app = express();
const port = 3000;

// Define a sample endpoint
app.get("/api/hello", (req, res) => {
  console.log("Hello");
  res.json({ message: "Hello, API!" });
});

// Start the server
app.listen(port, () => {
  console.log(`Server is listening at http://localhost:${port}`);
});
