import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QTableWidgetItem, QLabel
from PyQt6 import uic
from PyQt6.QtGui import QPixmap, QIcon
import json
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

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
        return True

    # Create new database
    try:
        cur.execute(f"CREATE DATABASE {dbname};")
    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        return False
    finally:
        cur.close()
        conn.close()
    return True

if __name__ == '__main__':
    # Database credentials
    dbname = "yelp"
    user = "postgres"
    password = "0213"

    # Create the database
    if not create_database(dbname, user, password):
        sys.exit("Failed to create database. Exiting.")

    # Connect to the new database
    conn = psycopg2.connect(dbname=dbname, user=user, password=password)
    cur = conn.cursor()

    #------------------LOAD JSON FILE------------------
    #load json file
    data = []
    with open('yelp_business.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data.append(json.loads(line))
    

    


    #create a postgresql database called 'yelp' with user 'postgres' and password '0213'
    #create a table called 'STATES' with column 'state'
    # conn = psycopg2.connect("dbname=yelp user=postgres password=0213")
    # cur = conn.cursor()

    #delete States table if it already exists
    cur.execute("DROP TABLE IF EXISTS states;")

    #---------------------Create State Table---------------------
    cur.execute("CREATE TABLE states (state varchar NOT NULL UNIQUE);")

    #insert unique states into table from the dictionary data
    for i in data:
        cur.execute("INSERT INTO states VALUES (%s) ON CONFLICT DO NOTHING;", (i['state'],))

    #sort the table by state
    cur.execute("SELECT * FROM states ORDER BY state ASC;")


    #---------------------Create City Tables---------------------
    #for every state in the states table, create a relational table for the cities in that state
    for i in cur.fetchall():
        cur.execute("CREATE TABLE " + i[0] + " (city varchar NOT NULL UNIQUE);")

    #insert unique cities into each state table from the dictionary data
    for i in data:
        cur.execute("INSERT INTO " + i['state'] + " VALUES (%s) ON CONFLICT DO NOTHING;", (i['city'],))

    #print out the states table
    cur.execute("SELECT * FROM states ORDER BY state ASC;")
    print(cur.fetchall())



    #---------------------Create Zipcode Tables---------------------
    #for every city in every state, create a relational table for the zipcodes in that city
    # cur.execute("SELECT * FROM states ORDER BY state ASC;")
    # for i in cur.fetchall():
    #     cur.execute("SELECT * FROM " + i[0] + " ORDER BY city ASC;")
    #     for j in cur.fetchall():
    #         #replace all spaces with underscores of j[0]
    #         #create table if table doesnt already exist
    #         cur.execute("IF NOT EXISTS(CREATE TABLE " + i[0] + "_" + j[0].replace(" ", "_").replace("-","_") + " (zipcode varchar NOT NULL UNIQUE));")
    #         #cur.execute("CREATE TABLE " + i[0] + "_" + j[0].replace(" ", "_").replace("-","_") + " (zipcode varchar NOT NULL UNIQUE);")

    
        


    


    

    cur.close()
    conn.close()