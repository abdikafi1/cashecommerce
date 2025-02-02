const express = require('express');
const Product = require('../models/productModel');  // Import the Product model

const router = express.Router();

// Create product
router.post('/products', async (req, res) => {
  const { name, price, description, imageUrl } = req.body;

  const newProduct = new Product({ name, price, description, imageUrl });
  await newProduct.save();

  // Fetch updated list of products and return it
  const products = await Product.find();
  res.status(201).json(products); // Return the updated list of products
});

// Get all products
router.get('/products', async (req, res) => {
  const products = await Product.find();
  res.json(products);
});

module.exports = router;
