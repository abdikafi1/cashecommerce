const express = require('express');
const Transaction = require('../models/transactionModel');
const Product = require('../models/productModel'); // Assuming you have a Product model
const router = express.Router();

router.post('/transactions', async (req, res) => {
  const { userId, products, totalAmount } = req.body;

  try {
    // Ensure user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Process the transaction
    const newTransaction = new Transaction({
      userId,
      products,
      totalAmount,
      date: new Date(),
    });

    await newTransaction.save();

    res.status(201).json(newTransaction); // Transaction created successfully
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to create transaction", error: error.message });
  }
});
// Create a new transaction
// router.post('/transactions', async (req, res) => {
//   const { userId, products, totalAmount } = req.body;

//   const newTransaction = new Transaction({
//     userId,
//     products,
//     totalAmount,
//   });

//   try {
//     const savedTransaction = await newTransaction.save();
//     res.status(201).json(savedTransaction);
//   } catch (err) {
//     res.status(400).json({ message: 'Error creating transaction', error: err.message });
//   }
// });
// // get 
// router.get('/transactions', async (req, res) => {
//   try {
//     const transactions = await Transaction.find({ userId: req.userId });
//     res.json(transactions);
//   } catch (err) {
//     res.status(400).json({ message: 'Error fetching transactions', error: err.message });
//   }
// });

// In your transaction model (backend)
router.get('/transactions', async (req, res) => {
  try {
    // Fetch transactions and populate product details
    const transactions = await Transaction.find()
      .populate('products.product'); // Populate product details like name, price, etc.

    res.json(transactions);
  } catch (err) {
    res.status(400).json({ message: 'Error fetching transactions', error: err.message });
  }
});



module.exports = router;