import sys
from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6 import uic
import json


class MyApp(QMainWindow):
    def __init__(self):
        # Read business data
        file = open('./data/yelp_business.json')
        businessList = []
        self.loadData(file, businessList)

        # Read checkin data
        file = open('./data/yelp_checkin.json')
        checkinList = []
        self.loadData(file, checkinList)

        # Read review data
        file = open('./data/yelp_review.json')
        reviewList = []
        self.loadData(file, reviewList)

        # Read user data
        file = open('./data/yelp_user.json')
        userList = []
        self.loadData(file, userList)

        super().__init__()
        uic.loadUi('myGUI.ui', self)

    def loadData(self, file, list):
        lines = file.readlines()
        for line in lines:
            list.append(json.loads(line))


if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
