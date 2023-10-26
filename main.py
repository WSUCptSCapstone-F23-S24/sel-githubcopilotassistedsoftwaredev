import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QTableWidgetItem
from PyQt6 import uic
import json




#q: how do i add the city to the listWidget?
def updateList(self):
    self.listWidget.clear()
    data = []
    with open('yelp_business.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data.append(json.loads(line))
    cities = []
    for i in data:
        if i['state'] == self.comboBox.currentText():
            if i['city'] not in cities:
                cities.append(i['city'])
    cities.sort()
    for i in cities:
        self.listWidget.addItem(i)

#make UpdateList2
def updateList2(self):
    self.listWidget_2.clear()
    if self.listWidget.currentItem() == None: #modified
        return
    data = [] 
    with open('yelp_business.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data.append(json.loads(line))
    postal_codes = []
    for i in data:
        if i['state'] == self.comboBox.currentText():
            if i['city'] == self.listWidget.currentItem().text():
                if i['postal_code'] not in postal_codes:
                    postal_codes.append(i['postal_code'])
    postal_codes.sort()
    for i in postal_codes:
        self.listWidget_2.addItem(i)   

#make updateLabel to add total number of buisnesses in the zip code
def updateLabel(self):
    self.label_8.clear()
    if self.listWidget_2.currentItem() == None: #modified
        return
    data = [] 
    with open('yelp_business.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data.append(json.loads(line))
    count = 0
    for i in data:
        if i['postal_code'] == self.listWidget_2.currentItem().text():
            count += 1
    self.label_8.setText(str(count))

#make updateLable2 that sets the label_10 to the population of the zip code using the zipData.sql file
def updateLabel2(self):
    self.label_10.clear()
    if self.listWidget_2.currentItem() == None: #modified
        return
    data = [] 
    with open('zipData.sql', 'r', encoding="utf8") as sql_file:
        for line in sql_file:
            if line[0] != 'I':
                #tokenize the line and make a dictionary entry with the keys being zipcode,medianIncome,meanIncome,population
                line = line[1:-3]
                line = line.split(',')
                line = {'postal_code':line[0][1:-1], 'medianIncome':line[1], 'meanIncome':line[2], 'population':line[3]}
                data.append((line))
    population = 0
    for i in data:
        if i['postal_code'] == self.listWidget_2.currentItem().text():
            population = i['population']
    self.label_10.setText(str(population))

#make updateLable3 that sets the label_12 to the mean income of the zip code using the zipData.sql file
def updateLabel3(self):
    self.label_12.clear()
    if self.listWidget_2.currentItem() == None: #modified
        return
    data = [] 
    with open('zipData.sql', 'r', encoding="utf8") as sql_file:
        for line in sql_file:
            if line[0] != 'I':
                #tokenize the line and make a dictionary entry with the keys being zipcode,medianIncome,meanIncome,population
                line = line[1:-3]
                line = line.split(',')
                line = {'postal_code':line[0][1:-1], 'medianIncome':line[1], 'meanIncome':line[2], 'population':line[3]}
                data.append((line))
    meanIncome = 0
    for i in data:
        if i['postal_code'] == self.listWidget_2.currentItem().text():
            meanIncome = i['meanIncome']
    self.label_12.setText(str(meanIncome))    

#make updateTable that fills 2 columns with the number of buisnessies and uniqe categories
def updateTable(self):
    if self.listWidget_2.currentItem() == None: #modified
        return
    data = [] 
    with open('yelp_business.json', 'r', encoding="utf8") as json_file:
        for line in json_file:
            data.append(json.loads(line))
    categories = []
    for i in data:
        if i['postal_code'] == self.listWidget_2.currentItem().text():
            for j in i['categories']:
                if j not in categories:
                    categories.append(j)
    self.tableWidget_2.clear()
    self.tableWidget_2.setRowCount(len(categories))
    self.tableWidget_2.setColumnCount(2)
    col_headers = ['# Businesses', 'Category']
    self.tableWidget_2.setHorizontalHeaderLabels(col_headers)
    self.tableWidget_2.verticalHeader().setVisible(False)
    for i in categories:
        #set the 2nd column to the the categories
        self.tableWidget_2.setItem(categories.index(i), 1, QTableWidgetItem(i))
        count = 0
        for j in data:
            if j['postal_code'] == self.listWidget_2.currentItem().text():
                for k in j['categories']:
                    if i == k:
                        count += 1
        self.tableWidget_2.setItem(categories.index(i), 0, QTableWidgetItem(str(count)))

class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        uic.loadUi('myGUI.ui', self)

        #fill the ComboBox with unique "state" data from the yelp_business.json file
        data = [] # had to modify generated code to make a list of dictionaries
        with open('yelp_business.json', 'r', encoding="utf8") as json_file:
            for line in json_file: #modified
                data.append(json.loads(line)) #modified
        states = []
        for i in data:
            if i['state'] not in states:
                states.append(i['state'])
        states.sort()
        for i in states:
            self.comboBox.addItem(i)
        self.comboBox.setCurrentIndex(-1)

        #for each selected state, add the city to the listWidget
        self.comboBox.currentIndexChanged.connect(lambda: updateList(self))
        #for each selected city from the listWidget, add unique postal codes to the listWidget_2
        self.listWidget.currentItemChanged.connect(lambda: updateList2(self))
        #if another state is selected, clear the listWidget and listWidget_2

        #for each selected postal code from the listWidget_2, add the total number of businesses to the label_8
        self.listWidget_2.currentItemChanged.connect(lambda: updateLabel(self))
        self.listWidget_2.currentItemChanged.connect(lambda: updateLabel2(self))
        self.listWidget_2.currentItemChanged.connect(lambda: updateLabel3(self))
        self.listWidget_2.currentItemChanged.connect(lambda: updateTable(self))




if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')



#------------------QUESTIONS TO COPILOT------------------
    #q:how do i resolve 'charmap' codec can't decode byte 0x8d in position 1765090: character maps to <undefined>?
    #a: https://stackoverflow.com/questions/9233027/unicodedecodeerror-charmap-codec-cant-decode-byte-x-in-position-y-character
    #q:how do i load the json file as a dictionary rather than a list
    #a: https://stackoverflow.com/questions/2835559/parsing-values-from-a-json-file (wasnt helpful)