const express = require('express');
const sql = require('mssql');

const app = express();
app.use(express.urlencoded({ extended: true }));

// --- UPDATE THESE WITH YOUR DB DETAILS ---
const dbConfig = {
    user: 'dbmaster',
    password: 'Password__123',
    server: 'infra-sql-server-v2.database.windows.net', 
    database: 'infra_sql_database',
    options: {
        encrypt: true, 
        trustServerCertificate: true // Bypasses strict SSL for the private IP
    }
};


// 1. READ: Display the Dashboard
app.get('/', async (req, res) => {
    try {
        await sql.connect(dbConfig);
        
        // Fetch all data
        const users = await sql.query`SELECT * FROM Users`;
        const products = await sql.query`SELECT * FROM Products`;
        const orders = await sql.query`SELECT * FROM Orders`;

        // Format data into HTML lists
        let userRows = users.recordset.map(u => `<li style="margin-bottom:5px;"><strong>[ID: ${u.id}]</strong> ${u.username} <em>(${u.email})</em></li>`).join('');
        let prodRows = products.recordset.map(p => `<li style="margin-bottom:5px;"><strong>[ID: ${p.id}]</strong> ${p.name} - $${p.price}</li>`).join('');
        let orderRows = orders.recordset.map(o => `<li style="margin-bottom:5px;"><strong>Order ${o.id}:</strong> User ${o.user_id} bought Product ${o.product_id}</li>`).join('');

        res.send(`
            <html style="font-family: sans-serif; background-color: #f4f4f9; padding: 20px;"><body>
            <h2 style="color: #333;">E-Commerce Architecture Dashboard</h2>
            <hr>
            
            <div style="display:flex; gap: 40px; margin-top: 20px;">
                <div style="flex: 1; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <h3 style="color: #0056b3;">Users</h3>
                    <ul style="list-style-type: none; padding: 0;">${userRows || '<li>No users yet</li>'}</ul>
                    <hr>
                    <form method="POST" action="/add-user">
                        <h4>Add User</h4>
                        Username: <input type="text" name="username" required style="width: 100%; margin-bottom: 10px;"><br>
                        Password: <input type="password" name="password_hash" required style="width: 100%; margin-bottom: 10px;"><br>
                        Email: <input type="email" name="email" required style="width: 100%; margin-bottom: 10px;"><br>
                        <button type="submit" style="background: #0056b3; color: white; padding: 10px; border: none; width: 100%; cursor: pointer;">Create User</button>
                    </form>
                </div>

                <div style="flex: 1; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <h3 style="color: #28a745;">Products</h3>
                    <ul style="list-style-type: none; padding: 0;">${prodRows || '<li>No products yet</li>'}</ul>
                    <hr>
                    <form method="POST" action="/add-product">
                        <h4>Add Product</h4>
                        Name: <input type="text" name="name" required style="width: 100%; margin-bottom: 10px;"><br>
                        Price: <input type="number" step="0.01" name="price" required style="width: 100%; margin-bottom: 10px;"><br>
                        <button type="submit" style="background: #28a745; color: white; padding: 10px; border: none; width: 100%; cursor: pointer;">Create Product</button>
                    </form>
                </div>

                <div style="flex: 1; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <h3 style="color: #dc3545;">Orders</h3>
                    <ul style="list-style-type: none; padding: 0;">${orderRows || '<li>No orders yet</li>'}</ul>
                    <hr>
                    <form method="POST" action="/add-order">
                        <h4>Create Order</h4>
                        User ID: <input type="number" name="user_id" required style="width: 100%; margin-bottom: 10px;"><br>
                        Product ID: <input type="number" name="product_id" required style="width: 100%; margin-bottom: 10px;"><br>
                        <button type="submit" style="background: #dc3545; color: white; padding: 10px; border: none; width: 100%; cursor: pointer;">Place Order</button>
                    </form>
                </div>
            </div>
            </body></html>
        `);
    } catch (err) {
        res.status(500).send(`<h2>Connection Failed!</h2><p>${err.message}</p>`);
    }
});

// 2. CREATE: Add User (Removed ID from query)
app.post('/add-user', async (req, res) => {
    await sql.connect(dbConfig);
    await sql.query`INSERT INTO Users (username, password_hash, email) VALUES (${req.body.username}, ${req.body.password_hash}, ${req.body.email})`;
    res.redirect('/');
});

// 3. CREATE: Add Product (Removed ID from query)
app.post('/add-product', async (req, res) => {
    await sql.connect(dbConfig);
    await sql.query`INSERT INTO Products (name, price) VALUES (${req.body.name}, ${req.body.price})`;
    res.redirect('/');
});

// 4. CREATE: Add Order (Removed Order ID from query)
app.post('/add-order', async (req, res) => {
    await sql.connect(dbConfig);
    await sql.query`INSERT INTO Orders (user_id, product_id, order_date) VALUES (${req.body.user_id}, ${req.body.product_id}, GETDATE())`;
    res.redirect('/');
});

// Start server
app.listen(80, () => console.log('Relational Dashboard running on Port 80'));

