import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QTableWidgetItem, QLabel
from PyQt6 import uic
from PyQt6.QtGui import QPixmap, QIcon
import json
import Database



def make_tableWidget_2(self, cur, zipcode, city):
    self.tableWidget_2.setColumnCount(2)
    # remove vertical header
    self.tableWidget_2.verticalHeader().setVisible(False)
    categories = []
    categories_list = []
    num_businesses = []
    #display categories_list
    for i in Database.get_categories(cur, zipcode, city):
        #split by ", " and "," and remove '"' and "{" and "}"
        i = i.replace('"', '')
        i = i.replace('{', '')
        i = i.replace('}', '')
        i = i.replace(',', ', ')
        i = i.split(', ')
        for j in i:
            categories_list.append(j)
            if j not in categories:
                categories.append(j)
    for i in categories:
        #count the number of times the category appears in the lisT
        num_businesses.append(str(categories_list.count(i)))
    categories_list = []
    # fill categories list with a tuple (category, # of businesses)
    for i in range(len(categories)):
        categories_list.append((categories[i], num_businesses[i]))
    # sort categories list by # of businesses
    categories_list.sort(key=lambda x: int(x[1]), reverse=True)
    self.tableWidget_2.setRowCount(len(categories))
    self.tableWidget_2.setHorizontalHeaderLabels(['# of Businesses', 'Category'])
    for i in range(len(categories)):
        self.tableWidget_2.setItem(i, 1, QTableWidgetItem(categories_list[i][0]))
        self.tableWidget_2.setItem(i, 0, QTableWidgetItem(categories_list[i][1]))


class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        uic.loadUi('myGUI.ui', self)

        # run the make function in Database
        conn, cur = Database.make()

        # fill the combo box with states from the states table
        self.comboBox.addItems(Database.get_states(cur))
        self.listWidget.addItems(Database.get_cities(cur, self.comboBox.currentText()))

        # fill in the list widget with cities from the cities table of the state selected in the combo box using Database.get_cities that returns a list
        self.comboBox.currentTextChanged.connect(lambda: self.listWidget.clear())
        self.comboBox.currentTextChanged.connect(lambda: self.listWidget.addItems(Database.get_cities(cur, self.comboBox.currentText())))
        
        # if listwidget is empty, do nothing
        # else, fill in listwidget_2 with zipcodes from the zipcodes table of the city selected in the list widget using Database.get_zipcodes that returns a list
        self.listWidget.currentTextChanged.connect(lambda: self.listWidget_2.clear())
        self.listWidget.currentTextChanged.connect(lambda: self.listWidget_2.addItems(Database.get_zipcodes(cur, self.listWidget.currentItem().text())) if self.listWidget.currentItem() else None)

        # fill in label_8 with the total number of businesses in the zipcode selected in the listwidget_2 using Database.get_num_businesses that takes a zipcode and city and returns the number of businesses
        self.listWidget_2.currentTextChanged.connect(lambda: self.label_8.clear())
        self.listWidget_2.currentTextChanged.connect(lambda: self.label_8.setText(str(Database.get_num_businesses(cur, self.listWidget_2.currentItem().text(), self.listWidget.currentItem().text()))) if self.listWidget_2.currentItem() else None)

        # fill in label_10 with the total population in the zipcode selected in the listwidget_2 using Database.get_population that takes a zipcode and city and returns the population
        self.listWidget_2.currentTextChanged.connect(lambda: self.label_10.clear())
        self.listWidget_2.currentTextChanged.connect(lambda: self.label_10.setText(str(Database.get_population(cur, self.listWidget_2.currentItem().text()))) if self.listWidget_2.currentItem() else None)

        # fill in label_12 with the mean income of the zipcode selected in the listwidget_2 using Database.get_mean_income that takes a zipcode and city and returns the mean income
        self.listWidget_2.currentTextChanged.connect(lambda: self.label_12.clear())
        self.listWidget_2.currentTextChanged.connect(lambda: self.label_12.setText(str(Database.get_mean_income(cur, self.listWidget_2.currentItem().text()))) if self.listWidget_2.currentItem() else None)

        # fill in the 2nd collumn of tableWidget_2 with the categories from the businesses table using fill_categories that takes a cursor and returns a list
        self.listWidget_2.currentTextChanged.connect(lambda: self.tableWidget_2.clear())
        self.listWidget_2.currentTextChanged.connect(lambda: make_tableWidget_2(self, cur, self.listWidget_2.currentItem().text(), self.listWidget.currentItem().text()) if self.listWidget_2.currentItem() else None)
            
        
        # close the cursor
        self.pushButton.clicked.connect(lambda: cur.close())
        
        # close the connection
        self.pushButton.clicked.connect(lambda: conn.close())

if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
