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
        #count the number of times the category appears in the list
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
    # fill listwidget_4 with the categories
    self.listWidget_4.addItems(categories)

# make a function that takes (cur, zipcode, city) and fills tableWidget's 7 columns (business name, address, city, stars, review count, review rating, number of checkins)
def make_tableWidget(self, cur, zipcode, city, category):
    # make the table 7 columns
    self.tableWidget.setColumnCount(7)
    # remove vertical header
    self.tableWidget.verticalHeader().setVisible(False)
    # fill in the table header
    self.tableWidget.setHorizontalHeaderLabels(['Business Name', 'Address', 'City', 'Stars', 'Review Count', 'Review Rating', '# of Checkins'])
    businesses = Database.get_businesses(cur, zipcode, city)
    # sort businesses by [0]
    businesses.sort(key=lambda x: x[0])
    #reset row count
    self.tableWidget.setRowCount(0)
    for i in businesses:
        #tokenize the categories [6] and remove '"' and "{" and "}"  add to a list and replace [7] with the list
        processed = i[7].replace('"', '').replace('{', '').replace('}', '').replace(', ', ',').split(',')
        if category in processed:
            # add the business to the table
            self.tableWidget.setRowCount(self.tableWidget.rowCount() + 1)
            for j in range(len(i)-1):
                self.tableWidget.setItem(self.tableWidget.rowCount() - 1, j, QTableWidgetItem(str(i[j])))
    #resize the collumns to fit contents in the header
    self.tableWidget.resizeColumnsToContents()

def make_tableWidget_3(self, cur, zipcode, city):
    self.tableWidget_3.setColumnCount(4)
    self.tableWidget_3.verticalHeader().setVisible(False)
    # fill tableWidget_3 with a list of tuples (business name, stars, review rating, number of reviews)
    self.tableWidget_3.setRowCount(len(Database.get_business(cur, zipcode, city)))
    self.tableWidget_3.setHorizontalHeaderLabels(['Business Name', 'Stars', 'Review Rating', '# of Reviews'])
    temp = [];

    for i in (Database.get_business(cur, zipcode, city)):
        # self.tableWidget_3.setItem(i, 0, QTableWidgetItem(Database.get_business(cur, zipcode, city)[i][0]))
        # self.tableWidget_3.setItem(i, 1, QTableWidgetItem(str(Database.get_business(cur, zipcode, city)[i][3])))
        # self.tableWidget_3.setItem(i, 2, QTableWidgetItem(str(Database.get_business(cur, zipcode, city)[i][5])))
        # self.tableWidget_3.setItem(i, 3, QTableWidgetItem(str(Database.get_business(cur, zipcode, city)[i][4])))
        #make a list of tuples (business name, stars, review rating, number of reviews)
        temp.append((i[0], i[3], i[5], i[4]))
    #sort the list of tuples by review rating
    temp.sort(key=lambda x: x[2], reverse=True)
    for i in range(len(temp)):
        self.tableWidget_3.setItem(i, 0, QTableWidgetItem(temp[i][0]))
        self.tableWidget_3.setItem(i, 1, QTableWidgetItem(str(temp[i][1])))
        self.tableWidget_3.setItem(i, 2, QTableWidgetItem(str(temp[i][2])))
        self.tableWidget_3.setItem(i, 3, QTableWidgetItem(str(temp[i][3])))

#make tableWidget_4 that fills in the table with businesses in the current zipcode. The first column is business name, the second is review count, the third is number of checkins
def make_tableWidget_4(self, cur, zipcode, city):
    self.tableWidget_4.setColumnCount(3)
    # remove vertical header
    self.tableWidget_4.verticalHeader().setVisible(False)
    # fill tableWidget_4 with a list of tuples (business name, review count, number of checkins)
    self.tableWidget_4.setRowCount(len(Database.get_business(cur, zipcode, city)))
    self.tableWidget_4.setHorizontalHeaderLabels(['Business Name', 'Review Count', '# of Checkins'])
    temp = [];
    for i in (Database.get_business(cur, zipcode, city)):
        # self.tableWidget_4.setItem(i, 0, QTableWidgetItem(Database.get_business(cur, zipcode, city)[i][0]))
        # self.tableWidget_4.setItem(i, 1, QTableWidgetItem(str(Database.get_business(cur, zipcode, city)[i][4])))
        # self.tableWidget_4.setItem(i, 2, QTableWidgetItem(str(Database.get_business(cur, zipcode, city)[i][6])))
        #make a list of tuples (business name, review count, number of checkins)
        temp.append((i[0], i[4], i[6]))
    #sort the list of tuples by checkins
    temp.sort(key=lambda x: x[2], reverse=True)
    for i in range(len(temp)):
        self.tableWidget_4.setItem(i, 0, QTableWidgetItem(temp[i][0]))
        self.tableWidget_4.setItem(i, 1, QTableWidgetItem(str(temp[i][1])))
        self.tableWidget_4.setItem(i, 2, QTableWidgetItem(str(temp[i][2])))
    #increase first column by 200px
    self.tableWidget_4.setColumnWidth(0, 200)

class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        uic.loadUi('myGUI.ui', self)

        #Setting Icon for each button
        icon = QIcon('./image/Search.PNG')
        self.pushButton.setIcon(icon)
        self.pushButton.setIconSize(self.pushButton.size())
        icon2 = QIcon('./image/Clear.PNG')
        self.pushButton_2.setIcon(icon2)
        self.pushButton_2.setIconSize(self.pushButton.size())
        icon3 = QIcon('./image/Refresh.PNG')
        self.pushButton_3.setIcon(icon3)
        self.pushButton_3.setIconSize(self.pushButton.size())

        #image for zipcode statistics
        pixmap = QPixmap('./image/Cap.PNG')
        self.label_pic.setPixmap(pixmap)

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
        self.listWidget_2.currentTextChanged.connect(lambda: self.listWidget_4.clear())
        self.listWidget_2.currentTextChanged.connect(lambda: make_tableWidget_2(self, cur, self.listWidget_2.currentItem().text(), self.listWidget.currentItem().text()) if self.listWidget_2.currentItem() else None)
        
        # fill in tablewidget with  (business name, address, city, stars, review count, review rating, number of checkins) from the businesses table using fill_business
        self.listWidget_2.currentTextChanged.connect(lambda: self.tableWidget.clear())
        self.listWidget_4.currentTextChanged.connect(lambda: make_tableWidget(self, cur, self.listWidget_2.currentItem().text(), self.listWidget.currentItem().text(), self.listWidget_4.currentItem().text()) if self.listWidget_4.currentItem() else None)
        
        #fill in table_widget_3 with businesses in the current zipcode. The first column is business name, the second is stars, the third is review rating, and the last column is number of reviews
        self.listWidget_2.currentTextChanged.connect(lambda: self.tableWidget_3.clear())
        self.listWidget_2.currentTextChanged.connect(lambda: make_tableWidget_3(self, cur, self.listWidget_2.currentItem().text(), self.listWidget.currentItem().text()) if self.listWidget_2.currentItem() else None)
        #fill in table_widget_4 with businesses in the current zipcode. The first column is business name, the second is review count, the third is number of checkins
        self.listWidget_2.currentTextChanged.connect(lambda: self.tableWidget_4.clear())
        self.listWidget_2.currentTextChanged.connect(lambda: make_tableWidget_4(self, cur, self.listWidget_2.currentItem().text(), self.listWidget.currentItem().text()) if self.listWidget_2.currentItem() else None)
        
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
