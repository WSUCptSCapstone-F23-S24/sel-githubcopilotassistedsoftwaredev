import socket
import threading
from tkinter import *
from tkinter import scrolledtext

# Server address and port
server_address = 'localhost'
server_port = 12345

# Create a socket object
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to the server
client_socket.connect((server_address, server_port))

# Create a GUI window
window = Tk()
window.title("Client")

# Create a text area in the window for the chat
chat_area = scrolledtext.ScrolledText(window)
chat_area.pack()

# Create an entry field for the message
message_field = Entry(window)
message_field.pack()

def receive_message():
    while True:
        # Receive response from the server
        response = client_socket.recv(1024).decode()
        chat_area.insert(END, "Server: " + response + "\n")

def send_message(event):
    # Send message to the server
    message = message_field.get()
    client_socket.send(message.encode())
    message_field.delete(0, END)
    chat_area.insert(END, "You: " + message + "\n")

    # Check if the client wants to exit
    if message.lower() == 'exit':
        client_socket.close()
        window.quit()

def send_message_button_click():
    send_message(None)

# Bind the Enter key to the send_message function
window.bind("<Return>", send_message)

# Create a send button
send_button = Button(window, text="Send", command=send_message_button_click)
send_button.pack()

# Create a new thread for receiving messages from the server
receive_thread = threading.Thread(target=receive_message)
receive_thread.start()

# Start the GUI
window.mainloop()