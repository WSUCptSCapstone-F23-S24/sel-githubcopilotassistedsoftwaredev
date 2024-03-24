import socket
import re


def client_program():
    host = socket.gethostname()
    port = 5000
    
    
    client_socket = socket.socket()
    client_socket.connect((host,port))
    
    message = input(" -> ")
    
    while message.lower().strip() != 'bye':
        if(re.search("^Send \".*\"$", message)):
            # Send file
            filename = message[message.index('"')+1:-1]
            try:
                # Try to open file
                f = open(filename, 'r')
                message = "File Name \"" + filename + "\""
                client_socket.send(message.encode())

                # wait for ack
                client_socket.recv(1024).decode()

                # Now send file 1024 bytes at a time
                message = f.read(1024)
                while(message):
                    print("Sending " + str(len(message)) + " bytes")
                    client_socket.send(message.encode())

                    # await ack
                    client_socket.recv(1024).decode()
                    message = f.read(1024)
                
                # tell server file is done
                print("Done sending.")
                message = "Done: \"" + filename + "\""
                client_socket.send(message.encode())

            except:
                print("Error: Unable to find file.")
        else:
            # Send Message
            client_socket.send(message.encode())

        # await response
        data = client_socket.recv(1024).decode()
        print('Recieved from server: ' + data)

        # Recieving file
        if(re.search("^File Name \".*\"$", str(data))):

            # Creating file
            message = str(data)
            filename = message[message.index('"')+1:-1]
            f = open("client_" + filename, 'w')
            client_socket.send("okay".encode())

            # Recieve file data
            data = client_socket.recv(1024).decode()
            while (str(data) != "Done: \"" + filename + "\""):
                print("Recieving " + str(len(data)) + " bytes")
                f.write(data)
                client_socket.send("okay".encode())

                data = client_socket.recv(1024).decode()
            f.close()

        # get user message from commandline  
        message = input(" -> ")
        
    client_socket.close()
    
    
if __name__ == '__main__':
    client_program()