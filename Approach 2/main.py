import sys
from PyQt6.QtWidgets import *
from PyQt6 import uic

class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        print('hello world')
        self.ui = uic.loadUi('myGUI.ui', self)



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