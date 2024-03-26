#can you genorate the Client code of a client-server app using sockets. the app should facilitate instant message typechat functionality wherein messages sent from a client terminal should be visible on the serverterminal and vice versa. The app should also support file shares between the client and serverterminals. The client-server app interface can be either graphical or textual.
import socket

# Server address and port
server_address = 'localhost'
server_port = 12345

# Create a socket object
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to the server
client_socket.connect((server_address, server_port))

while True:
    # Send message to the server
    message = input("Enter your message: ")
    client_socket.send(message.encode())

    # Receive response from the server
    response = client_socket.recv(1024).decode()
    print("Server response:", response)

    # Check if the client wants to exit
    if message.lower() == 'exit':
        break

# Close the socket
client_socket.close()