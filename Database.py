import sys
import json
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

""" NOTES: 
    - States Table: Stores unique state codes with 'state_code' as the primary key.
    - Cities Table: Contains city names and their state codes, with 'city_id' as the primary key and 'state_code' as a foreign key.
    - Zipcodes Table: Records zip codes and associates them with cities using 'city_id'. Each entry has a unique 'zipcode_id' as the primary key.
    - Business Table: Holds details of businesses, including name and rating. Each business is linked to a specific location using 'zipcode_id' as a foreign key. The table uses 'business_id' as the primary key.
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

    #Create a single zipcode table with a foreign key
    cur.execute("""
        CREATE TABLE zipcodes (
            zipcode_id SERIAL PRIMARY KEY,
            zipcode varchar NOT NULL,
            city_id int REFERENCES cities(city_id),
            UNIQUE (zipcode, city_id)
        );
    """)
    #Insert zipcodes into the zipcode table
    for i in data:
        # Fetch city_id for the city in the current data item
        cur.execute("SELECT city_id FROM cities WHERE city_name = %s AND state_code = %s;", (i['city'], i['state']))
        city_id_result = cur.fetchone()
        if city_id_result:
            city_id = city_id_result[0]
            cur.execute("""
            INSERT INTO zipcodes (zipcode, city_id) 
            VALUES (%s, %s) 
            ON CONFLICT (zipcode, city_id) 
            DO NOTHING;
            """, (i['postal_code'], city_id))

    
    #print out all the zipcodes in the city of Phoenix
    cur.execute("SELECT zipcode FROM zipcodes WHERE city_id = 1 ORDER BY zipcode ASC;")
    print(cur.fetchall())

    
    #create a single business table with a foreign key
    cur.execute("""
        DROP TABLE IF EXISTS businesses;
        CREATE TABLE businesses (
            business_id SERIAL PRIMARY KEY,
            business_name varchar NOT NULL,
            rating float NOT NULL,
            zipcode_id int REFERENCES zipcodes(zipcode_id),
            UNIQUE (business_name, zipcode_id)
        );
    """)
    #Insert businesses into the business table
    for i in data:
        # Fetch zipcode_id for the zipcode in the current data item
        cur.execute("SELECT zipcode_id FROM zipcodes WHERE zipcode = %s;", (i['postal_code'],))
        zipcode_id_result = cur.fetchone()
        if zipcode_id_result:
            zipcode_id = zipcode_id_result[0]
            cur.execute("""
                INSERT INTO businesses (business_name, rating, zipcode_id) 
                VALUES (%s, %s, %s) 
                ON CONFLICT (business_name, zipcode_id) 
                DO NOTHING;
                """, (i['name'], i['stars'], zipcode_id))


    #Print out all the businesses in the zipcode 85003
    cur.execute("SELECT business_name FROM businesses WHERE zipcode_id = 1 ORDER BY business_name ASC;")
    print(cur.fetchall())

    
    conn.commit()

        

    # Close cursor and connection
    cur.close()
    conn.close()
