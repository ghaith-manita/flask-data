from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)

# MySQL database configuration
db_config = {
    "host": "sql7.freemysqlhosting.net",
    "user": "sql7747863",
    "password": "ZMrMP55Feu",
    "database": "sql7747863",
}

# Database helper function
def execute_query(query, values=None):
    try:
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor(dictionary=True)
        if values:
            cursor.execute(query, values)
        else:
            cursor.execute(query)
        if query.strip().upper().startswith("SELECT"):
            result = cursor.fetchall()
        else:
            connection.commit()
            result = {"status": "success", "affected_rows": cursor.rowcount}
        cursor.close()
        connection.close()
        return result
    except mysql.connector.Error as err:
        return {"status": "error", "message": str(err)}

# Test endpoint
@app.route("/api/test", methods=["GET"])
def test_connection():
    result = execute_query("SELECT 1")
    return jsonify(result)

# Insert data endpoint
@app.route("/api/insert", methods=["POST"])
def insert_data():
    data = request.json
    table_name = data.get("table_name")
    values = data.get("values")
    if not table_name or not values:
        return jsonify({"status": "error", "message": "Invalid input"}), 400

    # Dynamically construct the query
    columns = ", ".join(values.keys())
    placeholders = ", ".join(["%s"] * len(values))
    query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
    result = execute_query(query, tuple(values.values()))
    return jsonify(result)

# Fetch data endpoint
@app.route("/api/fetch", methods=["GET"])
def fetch_data():
    table_name = request.args.get("table_name")
    if not table_name:
        return jsonify({"status": "error", "message": "Table name is required"}), 400

    query = f"SELECT * FROM {table_name}"
    result = execute_query(query)
    return jsonify(result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
