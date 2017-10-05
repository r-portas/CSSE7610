/**
 * read-write.pml
 * @author Roy Portas - 43560846
 *
 */ 

byte WRITERS = 0;
byte READERS = 0;
byte INCREMENTERS = 2;

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

inline compareAndSet() {
    /* Mimic a compare and set */
    atomic {
        /* await c = 0 */
        c == 0;
        c = c + 1;
    }
}

inline get() {
    /* 
    The +1 on the end ensures that item will
    never equal 0 
    */
    item = (item % 255) + 1;
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
        
        compareAndSet();

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
                d1 = (x1 % 255) + 1;
                d2 = (x2 % 255) + 1;
                printf("hasUpdated=0\n");
            }

            compareAndSet();
            atomic {
                if
                :: (hasUpdated == 0) -> 
                    assert(d1 == (x1 % 255) + 1);
                    assert(d2 == (x2 % 255) + 1);

                    hasUpdated = 1;
                    /* printf("hasUpdated=1\n"); */
                    x1 = d1;
                    x2 = d2;
                    incrementData(d1, d2);
                :: else
                fi;
            }
            c = c - 1;

            /* This is a big portion to be atomic */
            /* But the c == 0 and c = c + 1 operations must be atomic */
            /* atomic { */
            /*     if */
            /*     :: (hasUpdated == 0 && c == 0) -> */
            /*         c = c + 1; */
            /*         assert(c == 1); */
            /*         /1* d1 = (x1 % 255) + 1; *1/ */
            /*         /1* d2 = (x2 % 255) + 1; *1/ */
            /*         incrementData(d1, d2); */

            /*         // Q2 (b) */
            /*         printf("%d  %d==%d hasUpdated=%d\n", _pid, d1, (x1 % 255) + 1, hasUpdated); */
            /*         assert(d1 == (x1 % 255) + 1); */
            /*         assert(d2 == (x2 % 255) + 1); */

            /*         atomic { */
            /*             hasUpdated = 1; */
            /*             printf("hasUpdated=1\n"); */
            /*             x1 = d1; */
            /*             x2 = d2; */
            /*         } */

            /*         c = c - 1; */
            /*         break; */
            /*     :: else */
            /*     fi; */
            /* } */
        od;

    od;
}
