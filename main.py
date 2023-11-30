import sys
from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6 import uic
import Database



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

        # fill in the listwidget_2 with zipcodes from the zipcodes table of the city selected in the list widget using Database.get_zipcodes that returns a list
        self.listWidget.currentTextChanged.connect(lambda: self.listWidget_2.clear())
        
        # if listwidget is empty, do nothing
        # else, fill in listwidget_2 with zipcodes from the zipcodes table of the city selected in the list widget using Database.get_zipcodes that returns a list
        self.listWidget.currentTextChanged.connect(lambda: self.listWidget_2.addItems(Database.get_zipcodes(cur, self.listWidget.currentItem().text())) if self.listWidget.currentItem() else None)

        # fill in label_8 with the total number of businesses in the zipcode selected in the listwidget_2 using Database.get_num_businesses that takes a zipcode and city and returns the number of businesses
        self.listWidget_2.currentTextChanged.connect(lambda: self.label_8.setText(str(Database.get_num_businesses(cur, self.listWidget_2.currentItem().text(), self.listWidget.currentItem().text()))))


if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
