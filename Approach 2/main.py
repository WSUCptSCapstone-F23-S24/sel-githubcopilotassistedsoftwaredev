import sys
from PyQt6.QtWidgets import *
from PyQt6 import uic
import psycopg2

class MyApp(QMainWindow):
    def __init__(self):
        # Setting up front-end
        super().__init__()
        self.ui = uic.loadUi('myGUI.ui', self)

        # Setting up database connection
        self.dbconnection = psycopg2.connect(
            host="localhost",
            database="postgres",
            user="postgres",
            password="123")
        self.cur = self.dbconnection.cursor()

        # Connecting location selectors to proper functions
        self.loadStates()
        self.ui.StateSelector.currentTextChanged.connect(self.updateCities)
        self.ui.CitySelector.currentTextChanged.connect(self.updateZipcodes)  

    def __del__(self):
        # Closing database connection
        self.cur.close()
        self.dbconnection.close()

    # Retrieve states from database and fill the state selector
    def loadStates(self):
        query = "select distinct state from business order by state"
        self.cur.execute(query)
        # reformats the returned value from the above query as a list
        result = [r[0] for r in self.cur.fetchall()]
        self.ui.StateSelector.addItems(result)

    # Update city selector based on selected state
    def updateCities(self):
        state = self.ui.StateSelector.currentText()
        self.ui.ZipcodeSelector.clearSelection()
        self.ui.ZipcodeSelector.clear()
        self.ui.CitySelector.clearSelection()
        self.ui.CitySelector.clear()

        query = "select distinct city from business where business.state='{}' order by city".format(state)
        self.cur.execute(query)
        result = [r[0] for r in self.cur.fetchall()]
        self.ui.CitySelector.addItems(result)

    # Update zipcode selector based on selected zipcode
    def updateZipcodes(self):
        if (self.ui.CitySelector.currentItem()):
            city = self.ui.CitySelector.currentItem().text()
            self.ui.ZipcodeSelector.clearSelection()
            self.ui.ZipcodeSelector.clear()

            query = "select distinct zipcode from business where business.city='{}' order by zipcode".format(city)
            self.cur.execute(query)
            result = [str(r[0]) for r in self.cur.fetchall()]
            self.ui.ZipcodeSelector.addItems(result)


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