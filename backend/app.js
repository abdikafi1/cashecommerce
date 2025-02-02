const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors')
const productRoutes = require('./routes/productRoutes');  // Import the routes
const transactionRoutes = require('./routes/transactionRoutes');
const authRoutes = require('./routes/authRoutes');
const app = express();
app.use(cors()); 
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api', productRoutes);  // Use the product routes
app.use('/api', transactionRoutes); 

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/productdb', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => {
    app.listen(5000, () => {
      console.log('Server is running on port 5000');
    });
  })
  .catch(err => console.log(err));
