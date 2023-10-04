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


    # make another grey background behind Zip Code information
    background2 = QLabel(window)
    background2.setStyleSheet("background-color: grey;")
    background2.move(700, 0)
    # make the size fit all of the selectors
    background2.resize(550, 200)

    # make a label for the zip code information
    zipCodeInfoLabel = QLabel(window)
    # set the text of the label
    zipCodeInfoLabel.setText("ZIP Code Information")
    # move the label above the zipcode selector
    zipCodeInfoLabel.move(900, 20)
    # make the label look nice
    zipCodeInfoLabel.setStyleSheet("color: black;")
    # resize the label
    zipCodeInfoLabel.resize(300, 25)
    # make the label text larger
    zipCodeInfoLabel.setFont(QFont("Arial", 15))

    # make a label for business under zip code information
    businessLabel = QLabel(window)
    # set the text of the label
    businessLabel.setText("Business")
    # move the label above the zipcode selector
    businessLabel.move(750, 50)
    # make the label look nice
    businessLabel.setStyleSheet("color: black;")
    # resize the label
    businessLabel.resize(100, 25)
    # make the label text larger
    businessLabel.setFont(QFont("Arial", 15))

    # make a label for population under business
    populationLabel = QLabel(window)
    # set the text of the label
    populationLabel.setText("Population")
    # move the label above the zipcode selector
    populationLabel.move(750, 100)
    # make the label look nice
    populationLabel.setStyleSheet("color: black;")
    # resize the label
    populationLabel.resize(100, 25)
    # make the label text larger
    populationLabel.setFont(QFont("Arial", 15))

    # make a label for average income under population
    averageIncomeLabel = QLabel(window)
    # set the text of the label
    averageIncomeLabel.setText("Average Income")
    # move the label above the zipcode selector
    averageIncomeLabel.move(750, 150)
    # make the label look nice
    averageIncomeLabel.setStyleSheet("color: black;")
    # resize the label
    averageIncomeLabel.resize(200, 25)
    # make the label text larger
    averageIncomeLabel.setFont(QFont("Arial", 15))

    # add text box for business
    businessTextBox = QLineEdit(window)
    # move the text box
    businessTextBox.move(900, 50)
    # make the text box look nice
    businessTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    businessTextBox.resize(300, 25)
    # make the text box text larger
    businessTextBox.setFont(QFont("Arial", 15))

    # add text box for population
    populationTextBox = QLineEdit(window)
    # move the text box
    populationTextBox.move(900, 100)
    # make the text box look nice
    populationTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    populationTextBox.resize(300, 25)
    # make the text box text larger
    populationTextBox.setFont(QFont("Arial", 15))

    # add text box for average income
    averageIncomeTextBox = QLineEdit(window)
    # move the text box
    averageIncomeTextBox.move(900, 150)
    # make the text box look nice
    averageIncomeTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    averageIncomeTextBox.resize(300, 25)
    # make the text box text larger
    averageIncomeTextBox.setFont(QFont("Arial", 15))




    # make another grey background behind Filter Categories
    background3 = QLabel(window)
    background3.setStyleSheet("background-color: grey;")
    background3.move(0, 200)
    # make the size fit all of the selectors
    background3.resize(300, 300)

    # make a label for the filter categories
    filterCategoriesLabel = QLabel(window)
    # set the text of the label
    filterCategoriesLabel.setText("Filter Categories")
    # move the label above the zipcode selector
    filterCategoriesLabel.move(65, 220)
    # make the label look nice
    filterCategoriesLabel.setStyleSheet("color: black;")
    # resize the label
    filterCategoriesLabel.resize(300, 25)
    # make the label text larger
    filterCategoriesLabel.setFont(QFont("Arial", 15))


    # add drop down menu under filter categories without another label
    filterCategoriesSelector = QComboBox(window)
    # move zipcode selector to the right of the city selector
    filterCategoriesSelector.move(20, 250)
    # make the zipcode selector look nice
    filterCategoriesSelector.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # set the size of the zipcode selector
    filterCategoriesSelector.resize(260, 25)
    # add 4 options to stateSelector
    filterCategoriesSelector.addItem("Select Filter Category")
    # add zipcodes to the stateSelector
    for filterCategory in foodEstablishments:
        filterCategoriesSelector.addItem(filterCategory)

    
    # make another grey background behind Filtered Businesses
    background4 = QLabel(window)
    background4.setStyleSheet("background-color: grey;")
    background4.move(550, 225)
    # make the size fit all of the selectors
    background4.resize(700, 250)

    # make a label for the filtered businesses
    filteredBusinessesLabel = QLabel(window)
    # set the text of the label
    filteredBusinessesLabel.setText("Filtered Businesses")
    # move the label above the zipcode selector
    filteredBusinessesLabel.move(575, 230)
    # make the label look nice
    filteredBusinessesLabel.setStyleSheet("color: black;")
    # resize the label
    filteredBusinessesLabel.resize(300, 25)
    # make the label text larger
    filteredBusinessesLabel.setFont(QFont("Arial", 15))

    # make label for name under filtered businesses
    nameLabel = QLabel(window)
    # set the text of the label
    nameLabel.setText("Name")
    # move the label above the zipcode selector
    nameLabel.move(575, 300)
    # make the label look nice
    nameLabel.setStyleSheet("color: black;")
    # resize the label
    nameLabel.resize(100, 25)
    # make the label text larger
    nameLabel.setFont(QFont("Arial", 15))

    # make label for address
    addressLabel = QLabel(window)
    # set the text of the label
    addressLabel.setText("Address")
    # move the label above the zipcode selector
    addressLabel.move(775, 300)
    # make the label look nice
    addressLabel.setStyleSheet("color: black;")
    # resize the label
    addressLabel.resize(100, 25)
    # make the label text larger
    addressLabel.setFont(QFont("Arial", 15))

    # make label rating
    ratingLabel = QLabel(window)
    # set the text of the label
    ratingLabel.setText("Rating")
    # move the label above the zipcode selector
    ratingLabel.move(975, 300)
    # make the label look nice
    ratingLabel.setStyleSheet("color: black;")
    # resize the label
    ratingLabel.resize(100, 25)
    # make the label text larger
    ratingLabel.setFont(QFont("Arial", 15))

    # make label for reviews
    reviewsLabel = QLabel(window)
    # set the text of the label
    reviewsLabel.setText("Reviews")
    # move the label above the zipcode selector
    reviewsLabel.move(1050, 300)
    # make the label look nice
    reviewsLabel.setStyleSheet("color: black;")
    # resize the label
    reviewsLabel.resize(100, 25)
    # make the label text larger
    reviewsLabel.setFont(QFont("Arial", 15))

    # make label for check-ins
    checkinsLabel = QLabel(window)
    # set the text of the label
    checkinsLabel.setText("Check-ins")
    # move the label above the zipcode selector
    checkinsLabel.move(1150, 300)
    # make the label look nice
    checkinsLabel.setStyleSheet("color: black;")
    # resize the label
    checkinsLabel.resize(100, 25)
    # make the label text larger
    checkinsLabel.setFont(QFont("Arial", 15))

    # add text box for name
    nameTextBox = QLineEdit(window)
    # move the text box
    nameTextBox.move(555, 325)
    # make the text box look nice
    nameTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    nameTextBox.resize(150, 25)
    # make the text box text larger
    nameTextBox.setFont(QFont("Arial", 15))

    # add text box for address
    addressTextBox = QLineEdit(window)
    # move the text box
    addressTextBox.move(700, 325)
    # make the text box look nice
    addressTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    addressTextBox.resize(260, 25)
    # make the text box text larger
    addressTextBox.setFont(QFont("Arial", 15))

    # add text box for rating
    ratingTextBox = QLineEdit(window)
    # move the text box
    ratingTextBox.move(960, 325)
    # make the text box look nice
    ratingTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    ratingTextBox.resize(80, 25)
    # make the text box text larger
    ratingTextBox.setFont(QFont("Arial", 15))
    
    # add text box for reviews
    reviewsTextBox = QLineEdit(window)
    # move the text box
    reviewsTextBox.move(1040, 325)
    # make the text box look nice
    reviewsTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    reviewsTextBox.resize(95, 25)
    # make the text box text larger
    reviewsTextBox.setFont(QFont("Arial", 15))

    # add text box for checkins
    checkinsTextBox = QLineEdit(window)
    # move the text box
    checkinsTextBox.move(1135, 325)
    # make the text box look nice
    checkinsTextBox.setStyleSheet("background-color: white; color: black; border: 1px solid black;")
    # resize the text box
    checkinsTextBox.resize(115, 25)
    # make the text box text larger
    checkinsTextBox.setFont(QFont("Arial", 15))




    # display the window
    window.show()
    # exit the window
    return window, app





# main function to call openwindow function
if __name__ == '__main__':
    window, app = openWindow()
    app.exec()
    
