import serial

def list_ports():
    import serial.tools.list_ports
    ports = []
    for n, (port, desc, hwid) in enumerate(sorted(serial.tools.list_ports.comports()), 1):
        ports.append(port)
    while True:
        port = 1
        try:
            index = int(port) - 1
            if not 0 <= index < len(ports):
                print('--- Invalid index!\n')
                continue
        except ValueError:
            print ('invalid value')
            pass
        else:
            port = ports[index]
        ser = serial.Serial(port, 9600, timeout=1)
        return ser 

def execute(command=None):
    try:
        ser = list_ports()
    except:
        print('Initialise - Failed')
        ser.close()
        return 
    try:
        # res = command_check(command)
        #     print('\t'+'Available Commands:')
        #     print('\t'*2+'SHOW DEGREE          : RETURN VALUES OF EACH SERVO')
        #     print('\t'*2+'HELP                 : HELP LIST')
        #     print('\t'*2+'QUIT                 : QUIT SCRIPT' )
        #     print('\t'*2+'SET %SETVO %DEGREE   : SET DEGREE OF A SERVO DIRECTLY; e.g. SET F 45 ')
        #     print('\t'*2+'ADD %SETVO %DEGREE   : ADD DEGREE OF A SERVO; e.g. ADD F 10 ')
        #     print('\t'*2+'MINUS %SETVO %DEGREE : MINUS DEGREE OF A SERVO; e.g. MINUS F 10 ')
        ser.write(command.encode())    
        s = ser.readlines(40)
        # if type(s) == str:
        #     print('\t'+s.decode('utf-8'))
        # else:
        #     for i in range(len(s)):
        #         print('\t'+s[i].decode('utf-8'))
        #     print()
    except:
        print('ERROR!')
        ser.close()
    command = None
    ser.close()


if __name__ == '__main__':
    execute('SET F 0')

# def set_default():

