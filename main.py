import sys
from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6 import uic


class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        uic.loadUi('myGUI.ui', self)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    myApp = MyApp()
    myApp.show()

    try:
        sys.exit(app.exec())
    except SystemExit:
        print('Closing Window...')
