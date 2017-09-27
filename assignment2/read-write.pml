/**
 * read-write.pml
 * @author Roy Portas - 43560846
 *
 */ 

byte WRITERS = 2;
byte READERS = 2;
byte INCREMENTERS = 2;

byte c = 0
byte x1 = 0;
byte x2 = 0;
byte item = 0;

inline readData(d1, d2) {
    printf("Reader #%d (%d, %d)\n", _pid, d1, d2);
}

inline writeData(d1, d2) {
    printf("Writer #%d (%d, %d)\n", _pid, d1, d2);
}

inline incrementData(d1, d2) {
    printf("Incrementer #%d (%d, %d)\n", _pid, d1, d2);

}

inline get() {
    /* 
    The +1 on the end ensures that item will
    never equal 0 
    */
    item = ((item+1) % 254) + 1;
}

active [READERS] proctype reader () {
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
            :: (c0 == 0 && hasRan2) -> break
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

active [WRITERS] proctype writer () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 
        /* await c = 0 */
        c == 0;

        c = c + 1;
        get();
        d1 = item;
        get();
        d2 = item;

        x1 = d1;
        x2 = d2;
        writeData(d1, d2);

        c = c - 1;

    od;
}

active [INCREMENTERS] proctype incrementer () {
    byte d1 = 0;
    byte d2 = 0;
    byte c0 = 0;
    do
    :: true -> 

        /* Create a variable to check that the loop has ran at
        least once */
        bool hasRan1 = 0;
        do
        :: (c0 == c && hasRan1) -> 
            /* The value for c hasn't changed, so update */
            x1 = d1;
            x2 = d2;
            incrementData(d1, d2);
            break;

        :: else -> 
            bool hasRan2 = 0;
            do
            :: (c0 == 0 && hasRan2) -> break
            :: else -> 
                c0 = c;
                hasRan2 = 1;
            od;

            d1 = x1 + 1;
            d2 = x2 + 1;

            hasRan1 = 1;
        od;

        /* use(d1, d2); */

    od;
}
