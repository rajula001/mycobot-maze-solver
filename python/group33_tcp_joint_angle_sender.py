import socket
import time
import csv


def send_message_via_tcp(sock_client, msg):
    """
    Send a message to the server and receive the response.
    """
    try:
        sock_client.sendall(msg.encode('utf-8'))
        server_reply = sock_client.recv(1024).decode('utf-8')
        print(f"Server response: {server_reply}")
        return server_reply
    except socket.error as err:
        print(f"Socket error: {err}")
        return None


def load_joint_angles_from_csv(file_location):
    joint_angles = []
    try:
        with open(file_location, mode='r') as csv_file:
            csv_reader = csv.reader(csv_file)
            for record in csv_reader:
                # Convert each angle to a float and append to joint_angles list
                joint_angles.append([float(joint) for joint in record])
        return joint_angles
    except FileNotFoundError:
        print(f"Error: File '{file_location}' not found.")
        return []
    except ValueError as err:
        print(f"Error: Invalid data in CSV file - {err}")
        return []


def execute_main_program():
    # Server details
    HOST_IP = '192.168.1.159'
    HOST_PORT = 5001

    # File containing joint angles
    csv_angles_file = r"C:\Users\abhip\Desktop\angles.csv"

    # Read angles from the CSV file
    joint_angles = load_joint_angles_from_csv(csv_angles_file)

    if not joint_angles:
        print("No joint angles to process. Exiting.")
        return

    # Establish the TCP connection once
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock_client:
            sock_client.connect((HOST_IP, HOST_PORT))
            print(f"Connected to server at {HOST_IP}:{HOST_PORT}")

            for angle_values in joint_angles:
                # Round angles to 2 decimal places
                precise_angles = [round(angle, 2) for angle in angle_values]
                # Prepare the message
                msg_to_send = f"set_angles({', '.join(map(str, precise_angles))}, 1200)"
                # Send the message and receive the response
                send_message_via_tcp(sock_client, msg_to_send)
                time.sleep(1)

    except socket.error as err:
        print(f"Error: Unable to connect to server - {err}")


if __name__ == "__main__":
    execute_main_program()
