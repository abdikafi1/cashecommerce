const express = require('express');
const bcrypt = require('bcrypt'); // Ensure bcrypt is required
const User = require('../models/user');
const router = express.Router();

// Register backend
 
router.post('/register', async (req, res) => {
  try {
    const { email, password, role } = req.body;
    
    
    // Create new user
    const newUser = new User({ email, password, role });
    
    // Save to the database
    await newUser.save();
    
    res.status(201).send({ message: 'User created successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).send({ message: 'Error registering user' });
  }
});


// login backend
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // Find user by email
  const user = await User.findOne({ email });

  if (!user || password !== user.password) {
    return res.status(401).send({ error: 'Invalid credentials' });
  }

  // Send user data (without token)
  res.send({
    userId: user._id,
    role: user.role,
    user: { email: user.email, role: user.role },  // Send relevant user data
  });

}
);

// exportin data 
module.exports = router;
