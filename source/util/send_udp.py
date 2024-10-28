import socket

udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_addr = ('192.168.2.101', 8080)
udp_socket.sendto("A".encode('utf-8'), udp_addr)
udp_socket.close()
