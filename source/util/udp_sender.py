import socket
import sys

msg_bytes_720p = 18
udp_msg = "00" * msg_bytes_720p
if len(sys.argv) != 0:
    udp_msg = sys.argv[1]
    print(udp_msg)

udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_addr = ('192.168.2.101', 8080)
udp_socket.sendto(bytes.fromhex(udp_msg), udp_addr)
udp_socket.close()
