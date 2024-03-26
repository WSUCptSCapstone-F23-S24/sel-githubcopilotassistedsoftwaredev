#can you genorate the Server code of a client-server app using sockets. the app should facilitate instant message typechat functionality wherein messages sent from a client terminal should be visible on the serverterminal and vice versa. The app should also support file shares between the client and serverterminals. The client-server app interface can be either graphical or textual.
import socket
import threading

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

def handle_client(client_socket, client_address):
    while True:
        # Receive data from the client
        data = client_socket.recv(1024).decode('utf-8')
        
        if not data:
            # If no data received, client has disconnected
            print(f'Client {client_address} has disconnected')
            clients.remove(client_socket)
            client_socket.close()
            break
        
        # Broadcast the received message to all connected clients
        for client in clients:
            client.sendall(data.encode('utf-8'))

def start_server():
    print(f'Server is listening on {SERVER_HOST}:{SERVER_PORT}')
    
    while True:
        # Accept a new connection
        client_socket, client_address = server_socket.accept()
        
        # Add the new client to the list
        clients.append(client_socket)
        
        # Start a new thread to handle the client
        client_thread = threading.Thread(target=handle_client, args=(client_socket, client_address))
        client_thread.start()

# Start the server
start_server()