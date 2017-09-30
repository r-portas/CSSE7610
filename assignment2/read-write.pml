/**
 * read-write.pml
 * @author Roy Portas - 43560846
 *
 */ 

byte WRITERS = 2;
byte READERS = 2;
byte INCREMENTERS = 3;

byte x1 = 0;
byte x2 = 0;
byte item = 0;

byte counter = 0;

/*
 * Mutual exclusion check
 */

/* Counter must be either 0 or 1 */
#define mutex (counter == 0 || counter == 1)
ltl mutexLtl { [] mutex }

/*
 * Freedom from starvation
 */

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
        :: (hasRan1 && x1 == d1 && x2 == d2) -> 
            /* The values have not updated, so break */
            break;
        :: else -> 
            d1 = x1;
            d2 = x2;
            hasRan1 = 1;
        od;

        readData(d1, d2);
    od;
}

active [WRITERS] proctype writer () {
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 

        do
        :: true -> 
            d1 = x1;
            d2 = x2;

            /* Compare and set */
            atomic {
                if
                :: d1 == x1 && d2 == x2 ->
                    counter = counter + 1;
                    // Simulate the get
                    get();
                    x1 = item;
                    get();
                    x2 = item;

                    writeData(x1, x2);
                    counter = counter - 1;
                    break;
                :: else
                fi;
            }

        od;
    od;
}

active [INCREMENTERS] proctype incrementer () {
    byte d1 = 0;
    byte d2 = 0;
    bool updated = 0;
    do
    :: true -> 

        do
        :: true -> 
            d1 = x1;
            d2 = x2;

            /* Compare and set */
            atomic {
                if
                :: d1 == x1 && d2 == x2 ->
                    counter = counter + 1;
                    x1 = (d1 % 255) + 1;
                    x2 = (d2 % 255) + 1;
                    incrementData(x1, x2);
                    counter = counter - 1;
                    break;
                :: else
                fi;
            }

        od;


    od;
}
