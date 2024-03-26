import socket
import threading
import tkinter as tk
from tkinter import scrolledtext

# Server configuration
SERVER_HOST = 'localhost'
SERVER_PORT = 12345

# Create a socket object
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to a specific address and port
server_socket.bind((SERVER_HOST, SERVER_PORT))

# Listen for incoming connections
server_socket.listen()

# List to store connected clients
clients = []

# Create a new window
window = tk.Tk()
window.title("Server")

# Create a new text widget
text_area = scrolledtext.ScrolledText(window)
text_area.pack()

# Create a new entry field
entry_field = tk.Entry(window)
entry_field.pack()

def send_message(event=None):
    message = entry_field.get()
    entry_field.delete(0, 'end')
    text_area.insert('end', f'Server: {message}\n')
    for client in clients:
        client.sendall(message.encode('utf-8'))

# Bind the Enter key to the send_message function
window.bind('<Return>', send_message)

# Create a new send button
send_button = tk.Button(window, text="Send", command=send_message)
send_button.pack()

def handle_client(client_socket, client_address):
    while True:
        # Receive data from the client
        data = client_socket.recv(1024).decode('utf-8')
        
        if not data:
            # If no data received, client has disconnected
            text_area.insert('end', f'Client {client_address} has disconnected\n')
            clients.remove(client_socket)
            client_socket.close()
            break
        
        # Display the message in the text widget
        text_area.insert('end', f'Client {client_address}: {data}\n')

def start_server():
    text_area.insert('end', f'Server is listening on {SERVER_HOST}:{SERVER_PORT}\n')
    
    while True:
        # Accept a new connection
        client_socket, client_address = server_socket.accept()
        
        # Add the new client to the list
        clients.append(client_socket)
        
        # Start a new thread to handle the client
        client_thread = threading.Thread(target=handle_client, args=(client_socket, client_address))
        client_thread.start()

# Start the server in a new thread
threading.Thread(target=start_server).start()

# Start the GUI
window.mainloop()