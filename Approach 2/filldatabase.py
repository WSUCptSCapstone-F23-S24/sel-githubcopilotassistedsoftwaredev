import json
import psycopg2

def loadFile(file):
        file = open(file)
        lines = file.readlines()
        items = []
        for line in lines:
            items.append(json.loads(line))
        file.close()
        return items

businessList = loadFile('../Approach 1/yelp_business.json')

# Read checkin data
checkinList = loadFile('../Approach 1/yelp_checkin.json')

# Read review data
reviewList = loadFile('../Approach 1/yelp_review.json')

# Read user data
userList = loadFile('../Approach 1/yelp_user.json')

# Read zipcode data
with open('../Approach 1/yelp_zipcode.JSON') as file:
    zipcodeData = json.load(file)

print(len(reviewList))

# Open database connection
# dbconnection = psycopg2.connect(
#     host="localhost",
#     database="postgres",
#     user="postgres",
#     password="123")
# cur = dbconnection.cursor()




# Below code fills zipcode table
# for zipcode in zipcodeData:
#      command = f"INSERT INTO zipcode(zipcode, population, avg_income) VALUES ({zipcode['zipcode']}, {zipcode['population']}, {zipcode['meanIncome']});"
#      cur.execute(command)




# Below code fills business table
# for business in businessList:
#     for checkin in checkinList:
#         if checkin['business_id'] == business['business_id']:
#             business_checkin = str(checkin['time']).replace("'", "\"")
#     categories = '['
#     for category in business['categories']:
#          categories += f'"{category}",'
#     categories = categories[:-1] + ']'
#     categories = categories.replace("'","''")
#     name = business['name'].replace("'", "''")
#     address = business['address'].replace("'", "''")
#     command = f"INSERT INTO business(business_id, categories, city, name, zipcode, review_count, stars, state, checkins, address) VALUES ('{business['business_id']}', '{categories}', '{business['city']}', '{name}', {business['postal_code']}, {business['review_count']}, {business['stars']}, '{business['state']}', '{business_checkin}','{address}');"
#     cur.execute(command)




# Below code fills review table
# for review in reviewList:
#      command = f"INSERT INTO review(review_id, business_id, stars, date) VALUES ('{review['review_id']}', '{review['business_id']}', {review['stars']}, '{review['date']}');"
#      cur.execute(command)




# Close database connection
# cur.close()
# dbconnection.commit()
# dbconnection.close()