#import PyQt6
from PyQt6.QtWidgets import *
from PyQt6.QtGui import *
from PyQt6.QtCore import *
import sys
import os
import time

# function to open a pyqt window
def openWindow():
    app = QApplication(sys.argv)
    window = QWidget()
    window.setWindowTitle("Business Application")
    window.setGeometry(100, 100, 280, 80)
    # add drop down menu to the window
    stateSelector = QComboBox(window)
    # add 4 options to stateSelector
    stateSelector.addItem("Select State")
    stateSelector.addItem("California")
    stateSelector.addItem("Texas")
    stateSelector.addItem("New York")
 
    if ConfirmationBox(window):
        window.show()
        sys.exit(app.exec())
    else:
        window.close()

# function to add 3 buttons that takes a window as a parameter and adds 3 buttons
def ConfirmationBox(window, message="Open Application?"):
    buttonReply = QMessageBox.question(window, 'Confirm', message, QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No, QMessageBox.StandardButton.No)
    if buttonReply == QMessageBox.StandardButton.Yes:
        return True
    else:
        return False

# main function to call openwindow function
if __name__ == '__main__':
    openWindow()