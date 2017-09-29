/**
 * read-write.pml
 * @author Roy Portas - 43560846
 *
 */ 

byte WRITERS = 2;
byte READERS = 2;
byte INCREMENTERS = 0;

bool hasUpdated = 0;
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
    item = (item % 254) + 1;
}

active [READERS] proctype reader () {
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 

        /* Create a variable to check that the loop has ran at
        least once */
        bool hasRan1 = 0;
        do
        :: (hasUpdated == 0 && hasRan1) -> break
        :: else -> 
            
            hasUpdated = 0;
            d1 = x1;
            d2 = x2;

            hasRan1 = 1;
        od;

        readData(d1, d2);
        /* use(d1, d2); */

    od;
}

active [WRITERS] proctype writer () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 
        
        /* Mimic a compare and set */
        atomic {
            /* await c = 0 */
            c == 0;
            c = c + 1;
        }

        /* c should always be 1 here */
        assert(c == 1);

        get();
        d1 = item;
        get();
        d2 = item;

        hasUpdated = 1;
        x1 = d1;
        x2 = d2;
        writeData(d1, d2);

        c = c - 1;

    od;
}

active [INCREMENTERS] proctype incrementer () {
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 

        do
        :: true -> 
            atomic {
                hasUpdated = 0;
                d1 = x1 + 1;
                d2 = x2 + 1;
                printf("%d Saving d1 and d2\n", _pid);
            }

            atomic {
                if
                :: (hasUpdated == 0 && c == 0) ->
                    c = c + 1;
                    printf("%d Incrementing c\n", _pid);
                    break;
                :: else
                fi;
            }
        od;

        /* The value for c hasn't changed, so update */
        assert(c == 1);
        incrementData(d1, d2);

        // Q2 (b)
        assert(d1 == x1 + 1);
        assert(d2 == x2 + 1);

        atomic {
            hasUpdated = 1;
            x1 = d1;
            x2 = d2;
        }

        c = c - 1;

    od;
}
