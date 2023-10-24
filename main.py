import sys
from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6 import uic
import json


class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.ui = uic.loadUi('myGUI.ui', self)

        # Load all data necessary for the application
        self.loadData() 

        # Connect data to UI elements
        self.ui.StateSelector.addItems(self.states)
        

    # Function to handle loading all data so init is cleaner
    def loadData(self):
        # Read business data
        self.businessList = self.loadFile('./data/yelp_business.json')

        # Read checkin data
        self.checkinList = self.loadFile('./data/yelp_checkin.json')

        # Read review data
        self.reviewList = self.loadFile('./data/yelp_review.json')

        # Read user data
        self.userList = self.loadFile('./data/yelp_user.json')

        self.states = self.loadStates()

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
    def loadStates(self):
        states = set()
        for business in self.businessList:
            states.add(business['state'])
        return list(states)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
