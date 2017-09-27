/**
 * read-write.pml
 * @author Roy Portas - 43560846
 *
 */ 

byte c = 0;
byte x1 = 0;
byte x2 = 0;
byte item = 0;

inline readData(d1, d2) {
    printf("Reader #%d (%d, %d)\n", _pid, d1, d2);
}

inline writeData(d1, d2) {
    /* printf("Writer #%d (%d, %d)\n", _pid, d1, d2); */
}

inline get() {
    item = (item+1) % 255;
}

active proctype reader () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 

        do
        :: true -> 
            
            do
            :: true -> 
                c0 = c;
                printf("Waiting: %d\n", c0);
                if 
                :: (c0 % 2 == 0) -> break
                fi;
            od;

            d1 = x1;
            d2 = x2;

            readData(d1, d2);

            if 
            :: (c0 == c) -> break
            fi;
        od;

        /* use(d1, d2); */

    od;
}

active proctype writer () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 
        get();
        d1 = item;
        get();
        d2 = item;

        /* Added modulus to prevent overflow */
        c = (c + 1) % 256;
        x1 = d1;
        x2 = d2;
        writeData(d1, d2);
        c = (c + 1) % 256;

    od;
}
