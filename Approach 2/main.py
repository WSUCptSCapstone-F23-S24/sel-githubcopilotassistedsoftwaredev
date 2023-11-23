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
        self.ui.ZipcodeSelector.currentTextChanged.connect(self.updateZipcodeStats)

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

    def updateZipcodeStats(self):
        if (self.ui.ZipcodeSelector.currentItem()):
            zipcode = self.ui.ZipcodeSelector.currentItem().text()
            query = "select population, avg_income from zipcode where zipcode.zipcode = {}".format(zipcode)
            self.cur.execute(query)
            result = self.cur.fetchall()[0]
            self.ui.populationCount.setText(str(result[0]))
            self.ui.avgIncome.setText(str(result[1]))

            query = "select categories from business where business.zipcode = {}".format(zipcode)
            self.cur.execute(query)
            result = [r[0] for r in self.cur.fetchall()]

            self.ui.BusinessCount.setText(str(len(result)))

            categories = dict()
            for row in result:
                for category in row:
                    if category in categories:
                        categories[category] += 1
                    else:
                        categories[category] = 1

            categories = sorted([(k, v) for k, v in categories.items()], key=lambda x : x[1], reverse=True)
            self.ui.BusinessCategories.clearContents()
            self.ui.BusinessCategories.setRowCount(len(categories))
            self.ui.BusinessCategories.verticalHeader().setVisible(False)
            for index in range(len(categories)):
                self.ui.BusinessCategories.setItem(index, 0, QTableWidgetItem(str(categories[index][1])))
                self.ui.BusinessCategories.setItem(index, 1, QTableWidgetItem(str(categories[index][0])))            


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