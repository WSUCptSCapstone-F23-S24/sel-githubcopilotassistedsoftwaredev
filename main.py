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

        # Connect data to UI elements
        self.ui.StateSelector.addItems(sorted(self.states))
        self.ui.CitySelector.addItems(sorted(self.cities))
        self.ui.ZipcodeSelector.addItems(sorted(self.zipcodes))
        self.ui.CategoryList.addItems(self.businesscategories.keys())
        self.ui.BusinessCount.setText(str(len(self.businessList)))

        self.ui.CategoryList.setSortingEnabled(True)

        self.ui.StateSelector.currentTextChanged.connect(self.updateCitySelector)
        self.ui.CitySelector.currentTextChanged.connect(self.updateZipcodeSelector)  
        self.ui.ZipcodeSelector.currentTextChanged.connect(self.updateZipCodeInfo)
        self.ui.SearchButton.clicked.connect(self.filterBusinessDisplay)
        self.ui.ResetSearch.clicked.connect(self.updateZipCodeInfo)
        self.fillBusinessDisplay(self.businessList)





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
            self.states.add(business['state'])
            self.cities.add(business['city'])
            self.zipcodes.add(business['postal_code'])

            if business['state'] in self.statetocity:
                self.statetocity[business['state']].add(business['city'])
            else:
                self.statetocity[business['state']] = set()
                self.statetocity[business['state']].add(business['city'])

            # print(self.statetocity)

            if business['city'] in self.citytozipcode:
                self.citytozipcode[business['city']].add(business['postal_code'])
            else:
                self.citytozipcode[business['city']] = set()
                self.citytozipcode[business['city']].add(business['postal_code'])
            # print(self.statetocity)

            if business['postal_code'] in self.zipcodetobusiness:
                self.zipcodetobusiness[business['postal_code']].append(business)
            else:
                self.zipcodetobusiness[business['postal_code']] = list()
                self.zipcodetobusiness[business['postal_code']].append(business)

            for category in business['categories']:
                if category in self.businesscategories:
                    self.businesscategories[category] = self.businesscategories[category] + 1
                else:
                    self.businesscategories[category] = 1

        categories = sorted([(k, v) for k, v in self.businesscategories.items()], key=lambda x : x[1], reverse=True)
        self.ui.BusinessCategories.clearContents()
        self.ui.BusinessCategories.setRowCount(len(categories))
        self.ui.BusinessCategories.verticalHeader().setVisible(False)
        for index in range(len(categories)):
             self.ui.BusinessCategories.setItem(index, 0, QTableWidgetItem(str(categories[index][1])))
             self.ui.BusinessCategories.setItem(index, 1, QTableWidgetItem(str(categories[index][0])))

        for entry in self.zipcodeData:
            self.zipcodeDataDict[entry['zipcode']] = (entry['medianIncome'], entry['meanIncome'], entry['population'])

    def loadBusinessData(self):
        self.businessRatings = dict()
        self.businessCheckins = dict()
        for review in self.reviewList:
            businessId = review['business_id']
            if businessId in self.businessRatings:
                self.businessRatings[businessId].append(review)
            else:
                self.businessRatings[businessId] = list()
                self.businessRatings[businessId].append(review)

        for checkin in self.checkinList:
            # print(checkin)
            self.businessCheckins[checkin['business_id']] = checkin
        
            

    def updateCitySelector(self):
        state = self.ui.StateSelector.currentText()
        self.ui.ZipcodeSelector.clearSelection()
        self.ui.ZipcodeSelector.clear()
        self.ui.CitySelector.clearSelection()
        self.ui.CitySelector.clear()
        self.ui.CitySelector.addItems(sorted(self.statetocity[str(state)]))


    def updateZipcodeSelector(self):
        if (self.ui.CitySelector.currentItem()):
            city = self.ui.CitySelector.currentItem().text()
            self.ui.ZipcodeSelector.clearSelection()
            self.ui.ZipcodeSelector.clear()
            self.ui.ZipcodeSelector.addItems(sorted(self.citytozipcode[str(city)]))


    def updateZipCodeInfo(self):
        if (self.ui.ZipcodeSelector.currentItem()):
            zipcode = self.ui.ZipcodeSelector.currentItem().text()
            self.ui.CategoryList.clearSelection()
            self.ui.CategoryList.clear()

            self.ui.BusinessCount.setText(str(len(self.zipcodetobusiness[zipcode])))

            currentcategories = dict()
            for business in self.zipcodetobusiness[zipcode]:
                for category in business['categories']:
                    if category in currentcategories:
                        currentcategories[category] = currentcategories[category] + 1
                    else:
                        currentcategories[category] = 1
            
            categories = sorted([(k, v) for k, v in currentcategories.items()], key=lambda x : x[1], reverse=True)
            self.ui.BusinessCategories.clearContents()
            self.ui.BusinessCategories.setRowCount(len(categories))
            self.ui.BusinessCategories.verticalHeader().setVisible(False)
            for index in range(len(categories)):
                self.ui.BusinessCategories.setItem(index, 0, QTableWidgetItem(str(categories[index][1])))
                self.ui.BusinessCategories.setItem(index, 1, QTableWidgetItem(str(categories[index][0])))
                self.ui.CategoryList.addItem(categories[index][0])

            self.ui.populationCount.setText(str(self.zipcodeDataDict[int(zipcode)][2]))
            self.ui.avgIncome.setText(str(self.zipcodeDataDict[int(zipcode)][1]))
            self.fillBusinessDisplay(self.zipcodetobusiness[zipcode])

    def fillBusinessDisplay(self, businessList):
        businessList = sorted(businessList, key=lambda x : x['name'])
        self.ui.BusinessDisplay.clearContents()
        self.ui.BusinessDisplay.setRowCount(len(businessList))
        self.ui.BusinessDisplay.verticalHeader().setVisible(False)
        for index in range(len(businessList)):
            self.ui.BusinessDisplay.setItem(index, 0, QTableWidgetItem(str(businessList[index]['name'])))
            self.ui.BusinessDisplay.setItem(index, 1, QTableWidgetItem(str(businessList[index]['address'])))
            self.ui.BusinessDisplay.setItem(index, 2, QTableWidgetItem(str(businessList[index]['city'])))
            self.ui.BusinessDisplay.setItem(index, 3, QTableWidgetItem(str(businessList[index]['stars'])))
            self.ui.BusinessDisplay.setItem(index, 4, QTableWidgetItem(str(len(self.businessRatings[businessList[index]['business_id']]))))\
            
            average = 0
            for review in self.businessRatings[businessList[index]['business_id']]:
                average = average + review['stars']
            average = average / len(self.businessRatings[businessList[index]['business_id']])
            self.ui.BusinessDisplay.setItem(index, 5, QTableWidgetItem(str(average)))

            if businessList[index]['business_id'] in self.businessCheckins:
                checkins = 0
                for day in self.businessCheckins[businessList[index]['business_id']]['time']:
                    for time in self.businessCheckins[businessList[index]['business_id']]['time'][day]:
                        checkins += self.businessCheckins[businessList[index]['business_id']]['time'][day][time]
            else:
                checkins = 0
            self.ui.BusinessDisplay.setItem(index, 6, QTableWidgetItem(str(checkins)))
    
    def filterBusinessDisplay(self):
        if (self.ui.CategoryList.currentItem()):
            category = self.ui.CategoryList.currentItem().text()
            if (self.ui.ZipcodeSelector.currentItem()):
                zipcode = self.ui.ZipcodeSelector.currentItem().text()
                businesses = filter(lambda x: category in x['categories'], self.zipcodetobusiness[zipcode])
            else:
                businesses = filter(lambda x: category in x['categories'], self.businessList)
            self.fillBusinessDisplay(businesses)

    # def resetBusinessDisplay(self):
    #     if (self.ui.CategoryList.currentItem()):

    
        

        

if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
