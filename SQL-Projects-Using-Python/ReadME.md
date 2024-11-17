Here’s a well-structured **README.md** file that documents the Python and SQL connection using pymysql, including code explanations and instructions: 

```markdown
# Python and SQL Integration using `pymysql`

This project demonstrates how to connect Python to an SQL database using the `pymysql` library.  
The guide covers database creation, table manipulation, and executing various SQL commands from Python. 

---

## Requirements

- Python 3.x
- `pymysql` library (Install it using `pip install pymysql`)
- MySQL or compatible database server

---

## Setup and Connection

### Step 1: Import the Required Library
Start by importing the `pymysql` library:
```python
import pymysql
```

### Step 2: Establish the Connection
Create a connection to the database using the `pymysql.connect` method:
```python
conn = pymysql.connect(
    host='localhost', 
    user='root', 
    password='Admin', 
    db='demo'
)
print(conn)
```
- Replace `localhost`, `root`, `Admin`, and `demo` with your database credentials.

---

## Cursor Creation
To execute SQL commands, create a cursor object:
```python
cur = conn.cursor()
```

---

## SQL Operations

### 1. Create a Database
```python
cur.execute("CREATE DATABASE demo")
print("Demo database created")
```

### 2. Create a Table
```python
cur.execute("""
CREATE TABLE employees (
    id INT PRIMARY KEY, 
    name VARCHAR(50), 
    age INT, 
    address VARCHAR(100), 
    salary FLOAT
)
""")
print("Table created")
```

### 3. Insert Data into the Table
```python
cur.execute("INSERT INTO employees VALUES (101, 'Sumit', 21, 'Prayagraj', 3500)")
cur.execute("INSERT INTO employees VALUES (102, 'Adarsh', 25, 'Ayodhya', 3600)")
cur.execute("INSERT INTO employees VALUES (103, 'Ankit', 22, 'Bihar', 3700)")
conn.commit()  # Commit DML commands to save changes
print("Records inserted")
```

---

## Fetching Data

### Fetch One Row
```python
cur.execute("SELECT * FROM employees")
data = cur.fetchone()
print(data)
```

### Fetch Multiple Rows
```python
data = cur.fetchmany(3)  # Fetch 3 rows
print(data)
```

### Fetch All Rows
```python
data = cur.fetchall()
print(data)
```

### Use a `for` Loop to Iterate Through Rows
```python
data = cur.fetchall()
for row in data:
    print(row)
```

---

## Updating Data
Update a record in the table:
```python
cur.execute("UPDATE employees SET name='Priya' WHERE id=101")
conn.commit()
print("Record updated")
```

---

## Deleting Data
Delete a specific record:
```python
cur.execute("DELETE FROM employees WHERE id=101")
conn.commit()
print("Record deleted")
```

---

## Closing the Connection
Always close the connection after executing all operations:
```python
conn.close()
print("Connection closed")
```

---

## Full Code
Here’s the complete Python script:
```python
import pymysql

# Connect to the database
conn = pymysql.connect(host='localhost', user='root', password='Admin', db='demo')
cur = conn.cursor()

# Create database
cur.execute("CREATE DATABASE demo")
print("Demo database created")

# Create table
cur.execute("""
CREATE TABLE employees (
    id INT PRIMARY KEY, 
    name VARCHAR(50), 
    age INT, 
    address VARCHAR(100), 
    salary FLOAT
)
""")
print("Table created")

# Insert records
cur.execute("INSERT INTO employees VALUES (101, 'Sumit', 21, 'Prayagraj', 3500)")
cur.execute("INSERT INTO employees VALUES (102, 'Adarsh', 25, 'Ayodhya', 3600)")
cur.execute("INSERT INTO employees VALUES (103, 'Ankit', 22, 'Bihar', 3700)")
conn.commit()
print("Records inserted")

# Fetch data
cur.execute("SELECT * FROM employees")
data = cur.fetchall()
for row in data:
    print(row)

# Update data
cur.execute("UPDATE employees SET name='Priya' WHERE id=101")
conn.commit()
print("Record updated")

# Delete data
cur.execute("DELETE FROM employees WHERE id=101")
conn.commit()
print("Record deleted")

# Close connection
conn.close()
print("Connection closed")
```

---

## Notes
1. Use `commit()` after any DML operations (INSERT, UPDATE, DELETE) to apply changes to the database.
2. Ensure your MySQL server is running and credentials are correct.
3. Replace database details (`host`, `user`, `password`, `db`) as per your environment.

---

## Author
- **Rishi Maddheshiya**  
  - [LinkedIn Profile](https://www.linkedin.com/in/rishi-maddheshiya-020b14267/)  
  - [Portfolio Website](https://sites.google.com/view/rishi-portfolioo/home)  

---

## Contributions
Feel free to contribute by opening an issue or submitting a pull request. 😊

---

## License
This project is licensed under the MIT License.
```

This updated file includes your LinkedIn profile and portfolio website under the **Author** section for better visibility.
