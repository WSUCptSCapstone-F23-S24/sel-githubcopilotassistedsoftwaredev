import sys
import json
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

""" NOTES: 
    - States Table: Stores unique state codes with 'state_code' as the primary key.
    - Cities Table: Contains city names and their state codes, with 'city_id' as the primary key and 'state_code' as a foreign key.
    - Business Table: Holds details of businesses, including name, rating, and city. It uses 'business_id' as the primary key and links to cities through 'city_id'.
"""


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

    #Create a single Business Table with a Foreign Key
    cur.execute("""
        CREATE TABLE business (
            business_id varchar PRIMARY KEY NOT NULL UNIQUE,
            business_name varchar NOT NULL,
            city_id int REFERENCES cities(city_id),
            stars float,
            review_count int,
            is_open int
        );
    """)

    # Insert business into the Business table
    for i in data:
        # Fetch city_id for the city from the cities table
        cur.execute("SELECT city_id FROM cities WHERE city_name = %s AND state_code = %s;", (i['city'], i['state']))
        city_id = cur.fetchone()
        if city_id:
            city_id = city_id[0]
            # Check if the business already exists
            cur.execute("SELECT 1 FROM business WHERE business_id = %s;", (i['business_id'],))
            if not cur.fetchone():
                # If the business does not exist, insert it
                cur.execute("INSERT INTO business (business_id, business_name, city_id, stars, review_count, is_open) VALUES (%s, %s, %s, %s, %s, %s);", 
                            (i['business_id'], i['name'], city_id, i['stars'], i['review_count'], i['is_open']))

    
    # Commit the transactions
    conn.commit()

    #Print out the businesses in the city of Phoenix
    cur.execute("SELECT city_id FROM cities WHERE city_name = 'Phoenix' AND state_code = 'AZ';")
    phoenix_id = cur.fetchone()
    if phoenix_id:
        phoenix_id = phoenix_id[0]
        cur.execute("SELECT business_name FROM business WHERE city_id = %s ORDER BY business_name ASC;", (phoenix_id,))
        print(cur.fetchall())
        

    # Close cursor and connection
    cur.close()
    conn.close()
