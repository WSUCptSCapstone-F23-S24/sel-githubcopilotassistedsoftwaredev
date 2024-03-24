import socket
import re


def server_program():
    host = socket.gethostname()
    port = 5000
    
    server_socket = socket.socket()
    server_socket.bind((host,port))
    
    server_socket.listen(2)
    conn, address = server_socket.accept()
    print("Connection from: " + str(address))
    
    while True:
        data = conn.recv(1024).decode()
        if not data:
            break
            
        # print data
        print("from connected user: " + str(data))

        # Handle receiving file
        if(re.search("^File Name \".*\"$", str(data))):

            # Creating file
            message = str(data)
            filename = message[message.index('"')+1:-1]
            f = open("server_" + filename, 'w')
            conn.send("okay".encode())

            # recieve file
            data = conn.recv(1024).decode()
            while (str(data) != "Done: \"" + filename + "\""):
                print("Recieving " + str(len(data)) + " bytes")
                f.write(data)
                conn.send("okay".encode())

                data = conn.recv(1024).decode()
            f.close()

        # Get user input
        message = input (' -> ')
        
        # Handle sending file
        if(re.search("^Send \".*\"$", message)):
            # Send file
            filename = message[message.index('"')+1:-1]
            try:
                # Try to open file
                f = open(filename, 'r')
                message = "File Name \"" + filename + "\""
                conn.send(message.encode())

                # wait for ack
                conn.recv(1024).decode()

                # Now send file 1024 bytes at a time
                message = f.read(1024)
                while(message):
                    print("Sending " + str(len(message)) + " bytes")
                    conn.send(message.encode())

                    # await ack
                    conn.recv(1024).decode()
                    message = f.read(1024)
                
                # tell server file is done
                print("Done sending.")
                message = "Done: \"" + filename + "\""
                conn.send(message.encode())

            except:
                print("Error: Unable to find file.")
        else:
            # Send Message
            conn.send(message.encode())
        
    conn.close()
    
    
if __name__ == '__main__':
    server_program()