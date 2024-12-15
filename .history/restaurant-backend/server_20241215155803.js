const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const rateLimit = require('express-rate-limit');
const { check, validationResult } = require('express-validator');

dotenv.config();

const app = express();
app.use(express.json());


// Database connection
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('Connected to the database');
});

// JWT secret key
const JWT_SECRET = process.env.JWT_SECRET;

// Server start
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});


// Registration endpoint
app.post('/register', async (req, res) => {
    const { username, password } = req.body;

    try {
        // Password Hashing
        const hashedPassword = await bcrypt.hash(password, 12); // Use a salt round of 12

        const query = 'INSERT INTO Users (username, hashed_password) VALUES (?, ?)';
        db.query(query, [username, hashedPassword], (err, results) => {
            if (err) {
                console.error('Database error:', err); // Log the error for debugging
                return res.status(500).json({ error: 'Server error' });
            }
            res.json({ message: 'User registered successfully' });
        });
    } catch (err) {
        console.error('Error during registration:', err); // Log error
        return res.status(500).json({ error: 'Registration failed' });
    }
});

const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 25, // limit each IP to 5 requests per windowMs
    message: 'Too many login attempts from this IP, please try again after 15 minutes'
});

// Login endpoint
app.post('/login', loginLimiter, [
    check('username').isAlphanumeric().withMessage('Username must contain only letters and numbers'),
    check('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters long')
], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { username, password } = req.body;

    // Find user by username
    const query = 'SELECT * FROM Users WHERE username = ?';
    db.query(query, [username], async (err, results) => {
        if (err) {
            console.error('Database error:', err); // Log error
            return res.status(500).json({ error: 'Server error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = results[0];

        // Check password
        const isMatch = await bcrypt.compare(password, user.hashed_password);
        if (!isMatch) return res.status(401).json({ error: 'Invalid password' });

        // JWT generation
        const token = jwt.sign({ userId: user.user_id }, JWT_SECRET, { expiresIn: '1h' });
        res.json({ success:true, token });
    });
});

// middleware for Token Verification
const authenticateToken = (req, res, next) => {
    const token = req.headers['authorization'];
    if (!token) return res.status(401).json({ error: 'Access denied' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Invalid token' });
        req.user = user;
        next();
    });
};

// GET products
app.get('/products', (req, res) => {
    const query = 'SELECT * FROM Products';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ error: 'Server error' });
        }
        res.json(results);
    });
});

// Endpoint to add a new product
app.post('/add-product', [
    check('name').notEmpty().withMessage('Product name is required'),
    check('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    check('description').optional().isLength({ max: 500 }).withMessage('Description must not exceed 500 characters'),
    check('image_url').optional().isURL().withMessage('Image URL must be valid')
], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { name, description, price, image_url } = req.body;

    const query = 'INSERT INTO Products (name, description, price, image_url) VALUES (?, ?, ?, ?)';
    db.query(query, [name, description, price, image_url], (err, results) => {
        if (err) {
            console.error('Database error:', err); // Log the error for debugging
            return res.status(500).json({ error: 'Database error' });
        }
        res.status(201).json({ message: 'Product added successfully', productId: results.insertId });
    });
});

// ADD product to cart
app.post('/cart/add', authenticateToken, (req, res) => {
    const { productId, quantity } = req.body;
    const userId = req.user.userId;

    const query = 'INSERT INTO Cart (user_id, product_id, quantity) VALUES (?, ?, ?)';
    db.query(query, [userId, productId, quantity], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json({ message: 'Product added to cart' });
    });
});


// GET cart
app.get('/cart', (req, res) => {
    const userId = req.user.userId;

    const query = `
        SELECT Products.name, Products.price, Cart.quantity
        FROM Cart
        JOIN Products ON Cart.product_id = Products.product_id
        WHERE Cart.user_id = ?
    `;
    db.query(query, [userId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results);
    });
});


// REMOVE cart (OPTIONAL, ADMIN FEATURE MUST PRESENT)
app.delete('/cart/remove', authenticateToken, (req, res) => {
    const { productId } = req.body;
    const userId = req.user.userId;

    const query = 'DELETE FROM Cart WHERE user_id = ? AND product_id = ?';
    db.query(query, [userId, productId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json({ message: 'Product removed from cart' });
    });
});