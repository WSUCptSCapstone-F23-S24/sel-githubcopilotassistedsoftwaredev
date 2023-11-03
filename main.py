import sys
from PyQt6.QtWidgets import *
from PyQt6 import uic
import json


class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.ui = uic.loadUi('myGUI.ui', self)

        # Load all data necessary for the application
        self.loadData() 

        # Adding options to location selector
        self.ui.StateSelector.addItems(sorted(self.states))
        self.ui.CitySelector.addItems(sorted(self.cities))
        self.ui.ZipcodeSelector.addItems(sorted(self.zipcodes))
        self.ui.BusinessCount.setText(str(len(self.businessList)))

        # Connecting location selectors to proper functions
        self.ui.StateSelector.currentTextChanged.connect(self.updateCitySelector)
        self.ui.CitySelector.currentTextChanged.connect(self.updateZipcodeSelector)  
        self.ui.ZipcodeSelector.currentTextChanged.connect(self.updateZipCodeInfo)

        # Adding initial categories and businesses 
        self.ui.CategoryList.addItems(self.businesscategories.keys())
        self.ui.CategoryList.setSortingEnabled(True)
        self.fillBusinessDisplay(self.businessList)
        self.fillPopularBusinessDisplay(self.businessList)
        self.fillSuccessfulBusinessDisplay(self.businessList)

        # Connecting search and reset buttons to proper functions
        self.ui.SearchButton.clicked.connect(self.filterBusinessDisplay)
        self.ui.SearchButton.clicked.connect(self.filterPopularBusinessDisplay)
        self.ui.SearchButton.clicked.connect(self.filterSuccessfulBusinessDisplay)
        self.ui.ResetSearch.clicked.connect(self.updateZipCodeInfo)

        
    # Function to handle loading all data so init is cleaner
    def loadData(self):
        # Read business data
        self.businessList = self.loadFile('yelp_business.json')

        # Read checkin data
        self.checkinList = self.loadFile('yelp_checkin.json')

        # Read review data
        self.reviewList = self.loadFile('yelp_review.json')

        # Read user data
        self.userList = self.loadFile('yelp_user.json')
        
        # Read zipcode data
        with open('./yelp_zipcode.JSON') as file:
            self.zipcodeData = json.load(file)

        # Load location selector data
        self.loadLocations()
        self.loadBusinessData()


    # Loads data from file (formatted as 1 json object per line) and returns data in a list
    def loadFile(self, file):
        file = open(file)
        lines = file.readlines()
        items = []
        for line in lines:
            items.append(json.loads(line))
        file.close()
        return items
    

    # Iterates through self.businessList and returns a list of unique states
    def loadLocations(self):
        self.states, self.cities, self.zipcodes = set(), set(), set()
        self.statetocity, self.citytozipcode, self.zipcodetobusiness, self.businesscategories = dict(), dict(), dict(), dict()
        self.zipcodeDataDict = dict()
        for business in self.businessList:
            # Getting location selector lists
            self.states.add(business['state'])
            self.cities.add(business['city'])
            self.zipcodes.add(business['postal_code'])

            # Getting map of states -> cities in the state
            if business['state'] in self.statetocity:
                self.statetocity[business['state']].add(business['city'])
            else:
                self.statetocity[business['state']] = set()
                self.statetocity[business['state']].add(business['city'])

            # Getting map of cities -> zipcodes in the city
            if business['city'] in self.citytozipcode:
                self.citytozipcode[business['city']].add(business['postal_code'])
            else:
                self.citytozipcode[business['city']] = set()
                self.citytozipcode[business['city']].add(business['postal_code'])

            # Getting map of zipcode -> businesses in the zipcode
            if business['postal_code'] in self.zipcodetobusiness:
                self.zipcodetobusiness[business['postal_code']].append(business)
            else:
                self.zipcodetobusiness[business['postal_code']] = list()
                self.zipcodetobusiness[business['postal_code']].append(business)

            # Getting map of how many businesses in a category
            for category in business['categories']:
                if category in self.businesscategories:
                    self.businesscategories[category] = self.businesscategories[category] + 1
                else:
                    self.businesscategories[category] = 1

        # Loading initial list of categories sorted by how many businesses there are
        categories = sorted([(k, v) for k, v in self.businesscategories.items()], key=lambda x : x[1], reverse=True)
        self.ui.BusinessCategories.clearContents()
        self.ui.BusinessCategories.setRowCount(len(categories))
        self.ui.BusinessCategories.verticalHeader().setVisible(False)
        for index in range(len(categories)):
             self.ui.BusinessCategories.setItem(index, 0, QTableWidgetItem(str(categories[index][1])))
             self.ui.BusinessCategories.setItem(index, 1, QTableWidgetItem(str(categories[index][0])))

        # Getting map of zipcodes -> median income, mean income, and population in the zipcode
        for entry in self.zipcodeData:
            self.zipcodeDataDict[entry['zipcode']] = (entry['medianIncome'], entry['meanIncome'], entry['population'])


    # Load business reviews and checkin data 
    def loadBusinessData(self):
        self.businessRatings = dict()
        self.businessCheckins = dict()
        # Getting map of businessid -> reviews
        for review in self.reviewList:
            businessId = review['business_id']
            if businessId in self.businessRatings:
                self.businessRatings[businessId].append(review)
            else:
                self.businessRatings[businessId] = list()
                self.businessRatings[businessId].append(review)

        # Getting map of businessid -> checkins
        for checkin in self.checkinList:
            self.businessCheckins[checkin['business_id']] = checkin


    # Update cities and zipcodes options - when state is selected
    def updateCitySelector(self):
        # Getting state info & updating cities and zipcodes
        state = self.ui.StateSelector.currentText()
        self.ui.ZipcodeSelector.clearSelection()
        self.ui.ZipcodeSelector.clear()
        self.ui.CitySelector.clearSelection()
        self.ui.CitySelector.clear()
        self.ui.CitySelector.addItems(sorted(self.statetocity[str(state)]))


    # Update zipcode options - when city is selected
    def updateZipcodeSelector(self):
        # Getting selected city and updating zipcode options
        if (self.ui.CitySelector.currentItem()):
            city = self.ui.CitySelector.currentItem().text()
            self.ui.ZipcodeSelector.clearSelection()
            self.ui.ZipcodeSelector.clear()
            self.ui.ZipcodeSelector.addItems(sorted(self.citytozipcode[str(city)]))


    # Update statistics, categories, and businesses - when zipcode is selected
    def updateZipCodeInfo(self):
        if (self.ui.ZipcodeSelector.currentItem()):
            # Updating location information, categories, and businesses 
            zipcode = self.ui.ZipcodeSelector.currentItem().text()
            self.ui.CategoryList.clearSelection()
            self.ui.CategoryList.clear()
            self.ui.BusinessCount.setText(str(len(self.zipcodetobusiness[zipcode])))
            self.ui.populationCount.setText(str(self.zipcodeDataDict[int(zipcode)][2]))
            self.ui.avgIncome.setText(str(self.zipcodeDataDict[int(zipcode)][1]))
            self.fillBusinessDisplay(self.zipcodetobusiness[zipcode])

            # Getting counts of categories of businesses in zipcode
            currentcategories = dict()
            for business in self.zipcodetobusiness[zipcode]:
                for category in business['categories']:
                    if category in currentcategories:
                        currentcategories[category] = currentcategories[category] + 1
                    else:
                        currentcategories[category] = 1
            
            # Updating list of popular business categories in zipcode
            categories = sorted([(k, v) for k, v in currentcategories.items()], key=lambda x : x[1], reverse=True)
            self.ui.BusinessCategories.clearContents()
            self.ui.BusinessCategories.setRowCount(len(categories))
            self.ui.BusinessCategories.verticalHeader().setVisible(False)
            for index in range(len(categories)):
                self.ui.BusinessCategories.setItem(index, 0, QTableWidgetItem(str(categories[index][1])))
                self.ui.BusinessCategories.setItem(index, 1, QTableWidgetItem(str(categories[index][0])))
                self.ui.CategoryList.addItem(categories[index][0])
            

    # Fills the business table with businesses in the list in alphabetical order
    def fillBusinessDisplay(self, businessList):
        # Sorting given list to ensure businesses are alphabetical order
        businessList = sorted(businessList, key=lambda x : x['name'])
        self.ui.BusinessDisplay.clearContents()
        self.ui.BusinessDisplay.setRowCount(len(businessList))
        self.ui.BusinessDisplay.verticalHeader().setVisible(False)

        # Iterate through the list and add items to the table
        for index in range(len(businessList)):
            self.ui.BusinessDisplay.setItem(index, 0, QTableWidgetItem(str(businessList[index]['name'])))
            self.ui.BusinessDisplay.setItem(index, 1, QTableWidgetItem(str(businessList[index]['address'])))
            self.ui.BusinessDisplay.setItem(index, 2, QTableWidgetItem(str(businessList[index]['city'])))
            self.ui.BusinessDisplay.setItem(index, 3, QTableWidgetItem(str(businessList[index]['stars'])))
            self.ui.BusinessDisplay.setItem(index, 4, QTableWidgetItem(str(len(self.businessRatings[businessList[index]['business_id']]))))
            
            # Getting & adding average review
            average = 0
            for review in self.businessRatings[businessList[index]['business_id']]:
                average = average + review['stars']
            average = average / len(self.businessRatings[businessList[index]['business_id']])
            self.ui.BusinessDisplay.setItem(index, 5, QTableWidgetItem(str(average)))

            # Getting & adding number of checkins
            if businessList[index]['business_id'] in self.businessCheckins:
                checkins = 0
                for day in self.businessCheckins[businessList[index]['business_id']]['time']:
                    for time in self.businessCheckins[businessList[index]['business_id']]['time'][day]:
                        checkins += self.businessCheckins[businessList[index]['business_id']]['time'][day][time]
            else:
                checkins = 0
            self.ui.BusinessDisplay.setItem(index, 6, QTableWidgetItem(str(checkins)))
    

    # Limits businesses that are displayed to specified category if selected
    def filterBusinessDisplay(self):
        # Updating businessDisplay based on selected category
        if (self.ui.CategoryList.currentItem()):
            category = self.ui.CategoryList.currentItem().text()
            if (self.ui.ZipcodeSelector.currentItem()):

                # If selected zipcode, limit search to only within the zipcode
                zipcode = self.ui.ZipcodeSelector.currentItem().text()
                businesses = filter(lambda x: category in x['categories'], self.zipcodetobusiness[zipcode])
            else:

                # If no selected zipcode, show all businesses of that category
                businesses = filter(lambda x: category in x['categories'], self.businessList)
            self.fillBusinessDisplay(businesses)

    def fillPopularBusinessDisplay(self, businessList):
        businessList = sorted(businessList, key=lambda x : x['name'])
        self.ui.PopularBusinessDisplay.clearContents()
        self.ui.PopularBusinessDisplay.setRowCount(len(businessList))
        self.ui.PopularBusinessDisplay.verticalHeader().setVisible(False)

        for index in range(len(businessList)):
            self.ui.PopularBusinessDisplay.setItem(index, 0, QTableWidgetItem(str(businessList[index]['name'])))
            self.ui.PopularBusinessDisplay.setItem(index, 1, QTableWidgetItem(str(businessList[index]['stars'])))
            self.ui.PopularBusinessDisplay.setItem(index, 2, QTableWidgetItem(str(len(self.businessRatings[businessList[index]['business_id']]))))
            
            average = 0
            for review in self.businessRatings[businessList[index]['business_id']]:
                average = average + review['stars']
            average = average / len(self.businessRatings[businessList[index]['business_id']])
            self.ui.PopularBusinessDisplay.setItem(index, 3, QTableWidgetItem(str(average)))

    def filterPopularBusinessDisplay(self):
        if (self.ui.CategoryList.currentItem()):
            category = self.ui.CategoryList.currentItem().text()
            if (self.ui.ZipcodeSelector.currentItem()):
                zipcode = self.ui.ZipcodeSelector.currentItem().text()
                businesses = filter(lambda x: category in x['categories'] and x['stars'] >= 4.0, self.zipcodetobusiness[zipcode])
            else:
                businesses = filter(lambda x: category in x['categories'] and x['stars'] >= 4.0, self.businessList)
            self.fillPopularBusinessDisplay(businesses)

    def fillSuccessfulBusinessDisplay(self, businessList):
        businessList = sorted(businessList, key=lambda x : x['name'])
        self.ui.SuccessfulBusinessDisplay.clearContents()
        self.ui.SuccessfulBusinessDisplay.setRowCount(len(businessList))
        self.ui.SuccessfulBusinessDisplay.verticalHeader().setVisible(False)

        for index in range(len(businessList)):
            self.ui.SuccessfulBusinessDisplay.setItem(index, 0, QTableWidgetItem(str(businessList[index]['name'])))

        review_count = len(self.businessRatings[businessList[index]['business_id']])
        self.ui.SuccessfulBusinessDisplay.setItem(index, 1, QTableWidgetItem(str(review_count)))

        checkin_count = self.calculateTotalCheckins(businessList[index]['business_id'])
        self.ui.SuccessfulBusinessDisplay.setItem(index, 2, QTableWidgetItem(str(checkin_count)))


    def filterSuccessfulBusinessDisplay(self):
        if (self.ui.CategoryList.currentItem()):
            category = self.ui.CategoryList.currentItem().text()
            if (self.ui.ZipcodeSelector.currentItem()):
                zipcode = self.ui.ZipcodeSelector.currentItem().text()
                businesses = filter(lambda x: category in x['categories'] and
                                  x['business_id'] in self.businessCheckins and
                                  self.calculateTotalCheckins(x['business_id']) >= 100, self.zipcodetobusiness[zipcode])
            else:
                businesses = filter(lambda x: category in x['categories'] and
                                  x['business_id'] in self.businessCheckins and
                                  self.calculateTotalCheckins(x['business_id']) >= 100, self.businessList)
            self.fillSuccessfulBusinessDisplay(list(businesses))

    def calculateTotalCheckins(self, business_id):
        if business_id in self.businessCheckins:
            checkins = self.businessCheckins[business_id]['time']
            total_checkins = 0
            for day, times in checkins.items():
                for time, count in times.items():
                    total_checkins += count
            return total_checkins
        return 0


    

        

if __name__ == '__main__':

    # Load application
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()
    
    # Ensure application can close
    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
