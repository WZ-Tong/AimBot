import socket
import sys
import time

color = 0
while True:
    start_x = sys.argv[1]
    start_y = sys.argv[2]
    end_x = sys.argv[3]
    end_y = sys.argv[4]

    start_x = (16*"0" + bin(int(start_x))[2:])[-11:]
    start_y = (16*"0" + bin(int(start_y))[2:])[-10:]
    end_x = (16*"0" + bin(int(end_x))[2:])[-11:]
    end_y = (16*"0" + bin(int(end_y))[2:])[-10:]
    color1 = (16*"0" + bin(int(color))[2:])[-6:]

    udp_msg = "udp_msg = 0b" + start_x + start_y + end_x + end_y + color1
    exec(udp_msg)
    udp_msg = (16*"0" + hex(udp_msg)[2:])[-12:]
    print(udp_msg)
    udp_msg = bytes.fromhex(udp_msg)
    print(udp_msg)

    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_addr = ('192.168.2.101', 8080)
    udp_socket.sendto(udp_msg, udp_addr)
    udp_socket.close()
    color = color + 1 if color != 63 else 0
    time.sleep(0.05)
