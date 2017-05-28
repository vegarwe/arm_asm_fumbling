
        AREA    MyData, DATA, READWRITE
        EXPORT data1
        EXPORT data2

data1   SPACE   255       ; defines 255 bytes of zeroed store
data2   FILL    50,0x63,1 ; defines 50 bytes containing 'c'

        END

