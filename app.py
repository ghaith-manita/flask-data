from flask import Flask, request, jsonify
import pymysql

app = Flask(__name__)

# Configure your MySQL connection
db_config = {
    'host': 'sql7.freemysqlhosting.net',
    'user': 'sql7747863',
    'password': 'ZMrMP55Feu',
    'database': 'sql7747863'
}

@app.route('/save_sms', methods=['POST'])
def save_sms():
    try:
        # Extract data from the request
        table_name = request.json.get('tableName')
        data = request.json.get('data')

        # Connect to the MySQL database
        connection = pymysql.connect(**db_config)
        cursor = connection.cursor()

        # Create an SQL query to insert the data
        sql_query = f"INSERT INTO {table_name} (data_column_name,Alarme) VALUES (%s,1)"
        cursor.execute(sql_query, (data,))
        connection.commit()

        return jsonify({'message': 'Data saved successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection:
            connection.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
