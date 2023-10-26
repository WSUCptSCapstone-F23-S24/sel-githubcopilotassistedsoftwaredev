import sys
from PyQt6.QtWidgets import QApplication, QMainWindow
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

        #for each selected state, add the city to the listWidget
        self.comboBox.currentIndexChanged.connect(lambda: updateList(self))
        #for each selected city from the listWidget, add unique postal codes to the listWidget_2
        self.listWidget.currentItemChanged.connect(lambda: updateList2(self))
        #if another state is selected, clear the listWidget and listWidget_2
        






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