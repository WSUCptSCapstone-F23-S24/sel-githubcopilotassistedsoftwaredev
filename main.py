import sys
from PyQt6.QtWidgets import QApplication, QWidget, QLabel, QPushButton

app = QApplication(sys.argv)

window = QWidget()
window.setWindowTitle("CptS421 - Case Study 1")
window.setGeometry(400, 400, 400, 200)

label = QLabel("Business Page:", window)
label.move(10, 10)

# utton = QPushButton("Click Me", window)
# button.move(150, 100)

# def on_button_click():
#    label.setText("Button Clicked!")

# button.clicked.connect(on_button_click)

window.show()

sys.exit(app.exec())