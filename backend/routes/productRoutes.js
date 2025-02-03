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

// Update product
router.put('/products/:id', async (req, res) => {
  const { id } = req.params;
  const { name, price, description, imageUrl } = req.body;

  try {
    const updatedProduct = await Product.findByIdAndUpdate(
      id,
      { name, price, description, imageUrl },
      { new: true }
    );

    if (!updatedProduct) {
      return res.status(404).json({ message: 'Product not found' });
    }

    res.json(updatedProduct);
  } catch (error) {
    res.status(500).json({ message: 'Error updating product', error });
  }
});

// Delete product
router.delete('/products/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const deletedProduct = await Product.findByIdAndDelete(id);

    if (!deletedProduct) {
      return res.status(404).json({ message: 'Product not found' });
    }

    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting product', error });
  }
});



module.exports = router;
