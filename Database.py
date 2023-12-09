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


 # make a function that creates a database with the given name, user, and password
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

def make():
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

    data2 = []
    with open('yelp_review.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data2.append(json.loads(line))
    
    data3 = []
    with open('yelp_checkin.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data3.append(json.loads(line))

    # append a review rating to each business in data using business id and data2
    review_rating_by_business = {}
    for i in data2:
        if i['business_id'] in review_rating_by_business:
            #add the stars
            review_rating_by_business[i['business_id']].append(i['stars'])
        else:
            review_rating_by_business[i['business_id']] = [i['stars']]
    
    mean_rating = {}
    for i in review_rating_by_business:
        mean_rating[i] = sum(review_rating_by_business[i])/len(review_rating_by_business[i])

    for i in data:
        if i['business_id'] in mean_rating:
            i['review_rating'] = mean_rating[i['business_id']]
        else:
            i['review_rating'] = 0
    
    # append a number of checkins to each business in data using business id and data3
    checkins_by_business = {}
    for i in data3:
        count = 0
        for day in i['time']:
            for hour in i['time'][day]:
                count += i['time'][day][hour]
        checkins_by_business[i['business_id']] = count

    for i in data:
        if i['business_id'] in checkins_by_business:
            i['num_checkins'] = checkins_by_business[i['business_id']]
        else:
            i['num_checkins'] = 0

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
    #cur.execute("SELECT * FROM states ORDER BY state_code ASC;")
    #print(cur.fetchall())

    #print out all the cities in the state of Arizona
    #cur.execute("SELECT city_name FROM cities WHERE state_code = 'AZ' ORDER BY city_name ASC;")
    #print(cur.fetchall())

    #Create a single zipcode table with a foreign key
    cur.execute("""
        CREATE TABLE zipcodes (
            zipcode_id SERIAL PRIMARY KEY,
            zipcode varchar NOT NULL,
            mean_income int NOT NULL,
            population int NOT NULL,
            city_id int REFERENCES cities(city_id),
            UNIQUE (zipcode, mean_income, population, city_id)
        );
    """)

    #make a dictionary of zipcodes with their mean income and population from zipData.sql
    zipdata = {}
    with open('zipData.sql', 'r', encoding="utf8") as zip_file:
        next(zip_file)
        for line in zip_file:
            #trim the starting '(' and ending ');\n' from each line
            line = line[1:-3]
            zipcode, medianIncome, meanIncome, population  = line.split(',')[:4]
            zipcode = zipcode.strip("'")
            zipdata[zipcode] = {'meanIncome': meanIncome, 'population': population}

    #Insert zipcodes into the zipcode table
    for i in data:
        # Fetch city_id for the city in the current data item
        cur.execute("SELECT city_id FROM cities WHERE city_name = %s AND state_code = %s;", (i['city'], i['state']))
        city_id_result = cur.fetchone()
        if city_id_result:
            city_id = city_id_result[0]
            cur.execute("""
            INSERT INTO zipcodes (zipcode, mean_income, population, city_id) 
            VALUES (%s, %s, %s, %s) 
            ON CONFLICT (zipcode, mean_income, population, city_id) 
            DO NOTHING;
            """, (i['postal_code'], zipdata[i['postal_code']]['meanIncome'], zipdata[i['postal_code']]['population'], city_id) if i['postal_code'] in zipdata else (i['postal_code'], 0, 0, city_id))
    


    #print out all the zipcodes in the city of Phoenix
    #cur.execute("SELECT zipcode FROM zipcodes WHERE city_id = 1 ORDER BY zipcode ASC;")
    #print(cur.fetchall())

    
    #create a single business table with a foreign key
    cur.execute("""
        DROP TABLE IF EXISTS businesses;
        CREATE TABLE businesses (
            business_id SERIAL PRIMARY KEY,
            business_name varchar NOT NULL,
            address varchar NOT NULL,
            stars float NOT NULL,
            review_count int NOT NULL,
            review_rating float NOT NULL,
            num_checkins int NOT NULL,
            categories varchar NOT NULL,
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
                INSERT INTO businesses (business_name, address, stars, review_count, review_rating, num_checkins, categories, zipcode_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s) 
                ON CONFLICT (business_name, zipcode_id) 
                DO NOTHING;
                """, (i['name'], i['address'], i['stars'], i['review_count'], "{:.1f}".format(i['review_rating']), i['num_checkins'], i['categories'], zipcode_id))

    #Print out all the businesses in the zipcode 85003
    #cur.execute("SELECT business_name FROM businesses WHERE zipcode_id = 1 ORDER BY business_name ASC;")
    #print(cur.fetchall())

    
    conn.commit()

    return conn, cur  

    # Close cursor and connection
    #cur.close()
    #conn.close()

# make get_states function that returns a sorted list of states from the states table
def get_states(cur):
    cur.execute("SELECT state_code FROM states ORDER BY state_code ASC;")
    return [i[0] for i in cur.fetchall()]

# make a get_cities function that returns a sorted list of cities from the cities table for the given state
def get_cities(cur, state):
    cur.execute("SELECT city_name FROM cities WHERE state_code = %s ORDER BY city_name ASC;", (state,))
    return [i[0] for i in cur.fetchall()]

# make a get_zipcodes function that returns a sorted list of zipcodes from the zipcodes table for the given city
def get_zipcodes(cur, city):
    cur.execute("SELECT zipcode FROM zipcodes WHERE city_id = (SELECT city_id FROM cities WHERE city_name = %s) ORDER BY zipcode ASC;", (city,))
    return [i[0] for i in cur.fetchall()]

# make a get_num_businesses function that returns the number of businesses in the given zipcode from the buisnesses table
def get_num_businesses(cur, zipcode, city):
    cur.execute("SELECT COUNT(*) FROM businesses WHERE zipcode_id = (SELECT zipcode_id FROM zipcodes WHERE zipcode = %s AND city_id = (SELECT city_id FROM cities WHERE city_name = %s));", (zipcode, city))
    return cur.fetchone()[0]

# make a get_population function that returns the population of the given zipcode from the zipcodes table
def get_population(cur, zipcode):
    cur.execute("SELECT population FROM zipcodes WHERE zipcode = %s;", (zipcode,))
    return cur.fetchone()[0]


# make a get_mean_income function that returns the mean income of the given zipcode from the zipcodes table
def get_mean_income(cur, zipcode):
    cur.execute("SELECT mean_income FROM zipcodes WHERE zipcode = %s;", (zipcode,))
    return cur.fetchone()[0]

# make a function that finds unique categories in the businesses table of the given city and zipcode
def get_categories(cur, zipcode, city):
    cur.execute("SELECT DISTINCT categories FROM businesses WHERE zipcode_id = (SELECT zipcode_id FROM zipcodes WHERE zipcode = %s AND city_id = (SELECT city_id FROM cities WHERE city_name = %s));", (zipcode, city))
    return [i[0] for i in cur.fetchall()]

# make a function that returns from the business tabel the business name, address, city, stars, review count, review rating, and number of checkins, and categories for the given city and zipcode
def get_business(cur, zipcode, city):
    cur.execute("SELECT business_name, address, city_name, stars, review_count, review_rating, num_checkins FROM businesses JOIN zipcodes USING (zipcode_id) JOIN cities USING (city_id) WHERE zipcode = %s AND city_name = %s;", (zipcode, city))
    return cur.fetchall()

# make a function that returns from the business tabel the business name, address, city, stars, review count, review rating, and number of checkins and categorys for the given city and zipcode
def get_businesses(cur, zipcode, city):
    cur.execute("SELECT business_name, address, city_name, stars, review_count, review_rating, num_checkins, categories FROM businesses JOIN zipcodes USING (zipcode_id) JOIN cities USING (city_id) WHERE zipcode = %s AND city_name = %s;", (zipcode, city))
    return cur.fetchall()
