#!/bin/python
import socket
import sys

#python -c 'import socket; import sys; s = socket.socket(socket.AF_INET); s.settimeout(5.0); s.connect((sys.argv[1], int(sys.argv[2]))); s.close();' vm-lin-jul1091 1521

try:
    s = socket.socket(socket.AF_INET)
    s.settimeout(5.0)
    s.connect((sys.argv[1], int(sys.argv[2])))
    s.close()
except:
    print( "Error - Port %s on %s is not responding" % (sys.argv[2], sys.argv[1]) )
    sys.exit(2)

print("OK - Port %s on %s is responding" % (sys.argv[2], sys.argv[1]))
