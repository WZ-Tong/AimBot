# pip install bitarray

import socket
import sys
from bitarray import bitarray

def gen_udp(start_x, start_y, end_x, end_y, color):
    start_x = (16*"0" + bin(int(start_x))[2:])[-11:]
    start_y = (16*"0" + bin(int(start_y))[2:])[-10:]
    end_x = (16*"0" + bin(int(end_x))[2:])[-11:]
    end_y = (16*"0" + bin(int(end_y))[2:])[-10:]
    color = (16*"0" + bin(int(color))[2:])[-6:]

    udp_msg = start_x + start_y + end_x + end_y + color
    udp_msg = bytes(bitarray(udp_msg))
    return udp_msg

if __name__ == '__main__':
    udp_msg = bytes();
    for i in range(len(sys.argv)//5):
        udp_msg = udp_msg + gen_udp(
            sys.argv[i*5+0+1],
            sys.argv[i*5+1+1],
            sys.argv[i*5+2+1],
            sys.argv[i*5+3+1],
            sys.argv[i*5+4+1],
        )
    print(udp_msg)
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_addr = ('192.168.2.101', 8080)
    udp_socket.sendto(udp_msg, udp_addr)
    udp_socket.close()
