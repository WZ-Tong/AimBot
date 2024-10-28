import socket
import sys

udp_msg = "A" * 16
if len(sys.argv) != 0:
    udp_msg = sys.argv[1]
    print(udp_msg)

udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_addr = ('192.168.2.101', 8080)
udp_socket.sendto(udp_msg.encode('utf-8'), udp_addr)
udp_socket.close()
