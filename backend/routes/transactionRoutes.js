const express = require('express');
const Transaction = require('../models/transactionModel');
const router = express.Router();

// Create a transaction
router.post('/', async (req, res) => {
  try {
    const { userId, products, totalAmount } = req.body;
    const transaction = new Transaction({ userId, products, totalAmount });
    await transaction.save();
    res.status(201).json(transaction);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get all transactions
router.get('/', async (req, res) => {
  try {
    const transactions = await Transaction.find().populate('userId products.productId');
    res.json(transactions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;