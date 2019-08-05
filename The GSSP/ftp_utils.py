from ftplib import FTP

IP = '146.169.197.126'
PUBLIC_FLAG = True
PUBLIC_NAME = 'wasabi'
PUBLIC_PASSWORD = '654456'

################################################################

def send_ftp(filename, address = IP, port = 2121):
    try:
        ftp = login_ftp(address, port)
        with open(filename, 'rb') as f:
            ftp.storbinary('STOR %s' % filename, f, 1024)
    finally:
        ftp.close()
        
def recv_ftp(filename, address = IP, port = 2121):
    try:
        ftp = login_ftp(address, port)
        if filename in ftp.nlst():
            ftp.retrbinary("RETR %s" % filename ,open(filename, 'wb').write)
        else:
            print('ERROR: file doesn\'t exist!')
    finally:
        ftp.close()
        
def exist_ftp(filename, address = IP, port = 2121):
    result = False
    try:
        ftp = login_ftp(address, port)
        if filename in ftp.nlst():
            result = True
        else:
            result = False
    finally:
        ftp.close()
        return result

def delete_ftp(filename, address = IP, port = 2121):
    try:
        ftp = login_ftp(address, port)
        if filename in ftp.nlst():
            ftp.delete(filename)
        else:
            print('ERROR: file doesn\'t exist!')
    finally:
        ftp.close()

################################################################

def waitState(targetState, address = IP, port = 2121):
    targetfile = 'state_%d' % targetState
    try:
        ftp = login_ftp(address, port)
        while True: 
            if targetfile in ftp.nlst():
                break
    finally:
        ftp.close()


def changeState(targetState, address = IP, port = 2121):
    targetfile = 'state_%d' % targetState
    try:
        ftp = login_ftp(address, port)
        for file in ftp.nlst():
            if file[:5] == 'state':
                ftp.delete(file)
        with open(targetfile, 'w+') as f:
            pass
        send_ftp(targetfile, address, port)
    finally:
        ftp.close()

def checkState(address = IP, port = 2121):
    try:
        ftp = login_ftp(address, port)
        for file in ftp.nlst():
            if file[:5] == 'state':
                return str(file[-1:])
        return -1
    finally:
        ftp.close()

################################################################

def login_ftp(address = IP, port = 2121):
    ftp = FTP()
    ftp.connect(address, port) 
    if PUBLIC_FLAG:
        ftp.login(PUBLIC_NAME, PUBLIC_PASSWORD)
    else:
        ftp.login()
    ftp.cwd('/ftp')
    return ftp
