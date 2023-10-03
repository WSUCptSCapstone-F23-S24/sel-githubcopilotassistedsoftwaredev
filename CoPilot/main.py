#import PyQt6
from PyQt6.QtWidgets import *
from PyQt6.QtGui import *
from PyQt6.QtCore import *
import sys
import os
import time

# create a list of zipcodes, states, and cities
zipcodes = ["99017", "99033","99102","99104","99111","99113","99163","99164"]
states = ["WA", "OR", "ID"]
cities = ["Seattle", "Pullman", "Portland", "Spokane", "Boise", "Moscow", "Tacoma", "Olympia"]



# function to open a pyqt window
def openWindow():
    app = QApplication(sys.argv)
    window = QWidget()
    window.setWindowTitle("Business Application")
    # make the window 720p
    window.resize(1280, 720)
    # make a grey background behind the zipcode selector
    background1 = QLabel(window)
    background1.setStyleSheet("background-color: grey;")
    background1.move(0, 0)
    # make the size fit all of the selectors
    background1.resize(405, 100)

    # make another selector for states
    stateSelector = QComboBox(window)
    # move state selector away from the edge of the window
    stateSelector.move(20, 50)
    # make the state selector look nice
    stateSelector.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # set the size of the state selector
    stateSelector.resize(100, 25)
    # add 4 options to stateSelector
    stateSelector.addItem("Select State")
    # add states to the stateSelector
    for state in states:
        stateSelector.addItem(state)
    # add a label above the state selector
    stateLabel = QLabel(window)
    # set the text of the label
    stateLabel.setText("State")
    # move the label above the state selector
    stateLabel.move(20, 20)
    # make the label look nice
    stateLabel.setStyleSheet("color: black;")
    # resize the label
    stateLabel.resize(100, 25)
    # make the label text larger
    stateLabel.setFont(QFont("Arial", 15))


    # make another selector for cities
    citySelector = QComboBox(window)
    # move city selector to the right of state selector
    citySelector.move(140, 50)
    # make the city selector look nice
    citySelector.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # set the size of the city selector
    citySelector.resize(100, 25)
    # add 4 options to stateSelector
    citySelector.addItem("Select City")
    # add cities to the citySelector
    for city in cities:
        citySelector.addItem(city)
    # add a label above the city selector
    cityLabel = QLabel(window)
    # set the text of the label
    cityLabel.setText("City")
    # move the label above the city selector
    cityLabel.move(140, 20)
    # make the label look nice
    cityLabel.setStyleSheet("color: black;")
    # resize the label
    cityLabel.resize(100, 25)
    # make the label text larger
    cityLabel.setFont(QFont("Arial", 15))

    # add drop down menu to the window
    zipcodeSelector = QComboBox(window)
    # move zipcode selector to the right of the city selector
    zipcodeSelector.move(260, 50)
    # make the zipcode selector look nice
    zipcodeSelector.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # set the size of the zipcode selector
    zipcodeSelector.resize(125, 25)
    # add 4 options to stateSelector
    zipcodeSelector.addItem("Select ZIP Code")
    # add zipcodes to the stateSelector
    for zipcode in zipcodes:
        zipcodeSelector.addItem(zipcode)
    # add a label above the zipcode selector
    zipcodeLabel = QLabel(window)
    # set the text of the label
    zipcodeLabel.setText("ZIP Code")
    # move the label above the zipcode selector
    zipcodeLabel.move(260, 20)
    # make the label look nice
    zipcodeLabel.setStyleSheet("color: black;")
    # resize the label
    zipcodeLabel.resize(100, 25)
    # make the label text larger
    zipcodeLabel.setFont(QFont("Arial", 15))




    # display the window
    window.show()
    # exit the window
    return window, app





# main function to call openwindow function
if __name__ == '__main__':
    window, app = openWindow()
    app.exec()
    