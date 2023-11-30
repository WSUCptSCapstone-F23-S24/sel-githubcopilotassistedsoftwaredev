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
        self.listWidget.currentTextChanged.connect(lambda: self.listWidget_2.addItems(Database.get_zipcodes(cur, self.listWidget.currentItem().text())))





if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
