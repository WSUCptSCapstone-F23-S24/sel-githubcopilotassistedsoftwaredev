import os
import socket
import threading
import tkinter as tk
from tkinter import scrolledtext
from tkinter import filedialog

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

def send_message():
    message = entry_field.get()
    if os.path.isfile(message):
        with open(message, 'rb') as file:
            for client in clients:
                client.sendall(b'FILE')
                client.sendfile(file, 0)
    else:
        text_area.insert('end', f'Server: {message}\n')
        for client in clients:
            client.sendall(b'TEXT')
            client.sendall(message.encode('utf-8'))
    entry_field.delete(0, 'end')

def send_file():
    file_path = filedialog.askopenfilename()
    if file_path:
        with open(file_path, 'rb') as file:
            for client in clients:
                client.sendall(b'FILE')
                client.sendfile(file, 0)
        text_area.insert('end', f'Server: {file_path}\n')


# Create a new send button
send_button = tk.Button(window, text="Send", command=send_message)
send_button.pack()

send_file_button = tk.Button(window, text="Send File", command=send_file)
send_file_button.pack()

def handle_client(client_socket, client_address):
    while True:
        # Receive flag from the client
        flag = client_socket.recv(4)

        # Receive data from the client
        data = client_socket.recv(1024)
        
        if not data:
            # If no data received, client has disconnected
            text_area.insert('end', f'Client {client_address} has disconnected\n')
            clients.remove(client_socket)
            client_socket.close()
            break

        if flag == b'TEXT':
            # Display the received message in the text area
            text_area.insert('end', f'Client {client_address}: {data.decode()}\n')
        elif flag == b'FILE':
            # Save the received file
            with open('received_file', 'wb') as file:
                file.write(data)
            
            # Display the received file path in the text widget
            text_area.insert('end', f'Client {client_address}: received_file\n')

            # Read and display the contents of the file
            with open('received_file', 'r') as file:
                contents = file.read()
            text_area.insert('end', "Contents: " + contents + "\n")
        
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

def on_close():
    # Close all client sockets
    for client_socket in clients:
        client_socket.close()
        print("Client socket closed")

    # Close the server socket
    server_socket.close()
    print("Server socket closed")

    # Stop the script
    window.destroy()

# Set the function to be called when the window is closed
window.protocol("WM_DELETE_WINDOW", on_close)

# Start the GUI
window.mainloop()