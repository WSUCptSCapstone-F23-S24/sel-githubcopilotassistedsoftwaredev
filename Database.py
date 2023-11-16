import sys
import json
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

""" NOTES: 
    -States Table: A table named 'states' is created with 'state_code' as its primary key. 
     This table stores unique state codes.
   - Cities Table: A table named 'cities' is created with 'city_id' as its primary key and 
     'state_code' as a foreign key. This table stores city names along with their corresponding 
     state codes, establishing a relational link between cities and states. """

def create_database(dbname, user, password):
    conn = psycopg2.connect(dbname="postgres", user=user, password=password)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()

    # Check if the database already exists
    cur.execute("SELECT 1 FROM pg_database WHERE datname = %s;", (dbname,))
    exists = cur.fetchone()
    if exists:
        cur.execute(f"DROP DATABASE IF EXISTS {dbname};")
    cur.execute(f"CREATE DATABASE {dbname};")

    cur.close()
    conn.close()

if __name__ == '__main__':
    # Database credentials
    dbname = "yelp"
    user = "postgres"
    password = "0213"

    # Create the database
    create_database(dbname, user, password)

    # Connect to the new database
    conn = psycopg2.connect(dbname=dbname, user=user, password=password)
    cur = conn.cursor()

    # Load JSON file
    data = []
    with open('yelp_business.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data.append(json.loads(line))

    # Create State Table with Primary Key
    cur.execute("CREATE TABLE states (state_code varchar PRIMARY KEY NOT NULL UNIQUE);")

    # Insert unique states into the table
    for i in data:
        cur.execute("INSERT INTO states (state_code) VALUES (%s) ON CONFLICT DO NOTHING;", (i['state'],))

    # Create a single Cities Table with a Foreign Key
    cur.execute("""
        CREATE TABLE cities (
            city_id SERIAL PRIMARY KEY,
            city_name varchar NOT NULL,
            state_code varchar REFERENCES states(state_code)
        );
    """)

    # Insert cities into the Cities table
    for i in data:
        # Check if the city already exists in the table for the given state
        cur.execute("SELECT 1 FROM cities WHERE city_name = %s AND state_code = %s;", (i['city'], i['state']))
        if not cur.fetchone():
            # If the city does not exist, insert it
            cur.execute("INSERT INTO cities (city_name, state_code) VALUES (%s, %s);", (i['city'], i['state']))

    # Commit the transactions
    conn.commit()

    # Print out the states table
    cur.execute("SELECT * FROM states ORDER BY state_code ASC;")
    print(cur.fetchall())

    #print out all the cities in the state of Arizona
    cur.execute("SELECT city_name FROM cities WHERE state_code = 'AZ' ORDER BY city_name ASC;")
    print(cur.fetchall())

    # Close cursor and connection
    cur.close()
    conn.close()
