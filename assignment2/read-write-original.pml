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
    printf("Writer #%d (%d, %d)\n", _pid, d1, d2);
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

        /* Create a variable to check that the loop has ran at
        least once */
        bool hasRan1 = 0;
        do
        :: (c0 == c && hasRan1) -> break
        :: else -> 
            
            bool hasRan2 = 0;
            do
            :: (c0 % 2 == 0 && hasRan2) -> break
            :: else -> 
                c0 = c;
                hasRan2 = 1;
            od;

            d1 = x1;
            d2 = x2;

            readData(d1, d2);
            hasRan1 = 1;
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

        /* This must be odd here */
        assert(c % 2 == 1);
        x1 = d1;
        x2 = d2;
        writeData(d1, d2);
        c = (c + 1) % 256;
        
        /* This must be even here */
        assert(c % 2 == 0);

    od;
}
