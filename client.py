import os
import socket
import threading
from tkinter import *
from tkinter import scrolledtext
from tkinter import filedialog

# Server address and port
server_address = 'localhost'
server_port = 12345

# Create a socket object
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to the server
try:
    client_socket.connect((server_address, server_port))
    connection_status = "Connected to the server"
except socket.error as e:
    connection_status = f"Failed to connect to the server: {e}"

# Create a GUI window
window = Tk()
window.title("Client")

# Create a label to display the connection status
connection_status_label = Label(window, text=connection_status)
connection_status_label.pack()

# Create a text area in the window for the chat
chat_area = scrolledtext.ScrolledText(window)
chat_area.pack()

# Create an entry field for the message
message_field = Entry(window)
message_field.pack()

def receive_message():
    while True:
        # Receive flag from the server
        flag = client_socket.recv(4)
        
        # Receive response from the server
        data = client_socket.recv(1024)
        
        if flag == b'TEXT':
            # Display the received message in the chat area
            chat_area.insert(END, "Server: " + data.decode() + "\n")
        elif flag == b'FILE':
            # Save the received file
            with open('received_file', 'wb') as file:
                file.write(data)
            
            # Display the received file path in the chat area
            chat_area.insert(END, "Server: received_file\n")

            # Read and display the contents of the file
            with open('received_file', 'r') as file:
                contents = file.read()
            chat_area.insert(END, "Contents: " + contents + "\n")

def send_message():
    # Send message to the server
    message = message_field.get()
    if os.path.isfile(message):
        client_socket.sendall(b'FILE')
        with open(message, 'rb') as file:
            client_socket.sendfile(file, 0)
    else:
        client_socket.sendall(b'TEXT')
        client_socket.send(message.encode())
    message_field.delete(0, END)
    chat_area.insert(END, "You: " + message + "\n")

def send_file():
    file_path = filedialog.askopenfilename()
    if file_path:
        client_socket.sendall(b'FILE')
        with open(file_path, 'rb') as file:
            client_socket.sendfile(file, 0)
        chat_area.insert(END, "You: " + file_path + "\n")

# Bind the Enter key to the send_message function
window.bind("<Return>", send_message)

# Create a send button
send_button = Button(window, text="Send", command=send_message)
send_button.pack()

send_file_button = Button(window, text="Send File", command=send_file)
send_file_button.pack()

# Create a new thread for receiving messages from the server
receive_thread = threading.Thread(target=receive_message)
receive_thread.start()

def on_close():
    # Close the client socket
    client_socket.close()
    print("Client closed")

    # Stop the script
    window.destroy()

# Set the function to be called when the window is closed
window.protocol("WM_DELETE_WINDOW", on_close)

# Start the GUI
window.mainloop()
