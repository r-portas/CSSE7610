/**
 * read-write.pml
 * @author Roy Portas - 43560846
 *
 */ 

byte WRITERS = 2;
byte READERS = 2;
byte INCREMENTERS = 2;

byte c = 0;
byte x1 = 0;
byte x2 = 0;
byte item = 0;

/* Counts the number of critical sections entered */
byte counter = 0;

/* Counter must be either 0 or 1 */
#define mutex (counter == 0 || counter == 1)
ltl mutexLtl { [] mutex }

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
    item = (item+1) % 255;
}

/* Semaphore implementation */

/* The binary semaphore */
byte s = 1;

inline wait(s) {
    atomic { s > 0; s-- };
}

inline signal(s) {
    s++;
}

active [READERS] proctype reader () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 
       /* Create a variable to check that the loop has ran at least once. */
        /* There is probably a better method to implement a repeat-until loop */
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

            /* This must be even here */
            assert(c0 % 2 == 0);

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
        get();
        d1 = item;
        get();
        d2 = item;

        wait(s);
        counter = counter + 1;

        /* Added modulus to prevent overflow */
        c = (c + 1) % 256;

        /* This must be odd here */
        assert(c % 2 == 1);
        x1 = d1;
        x2 = d2;
        writeData(d1, d2);
        c = (c + 1) % 256;

        counter = counter - 1;
        signal(s);

    od;
}

active [INCREMENTERS] proctype incrementer () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;

    bool locked = 0;
    do
    :: true -> 
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

            /* This must be even here */
            assert(c0 % 2 == 0);

            d1 = x1;
            d2 = x2;

            hasRan1 = 1;
        od;

        /* Perform a tryAcquire */
        atomic {
            if
            :: s > 0 ->
                s--;
                locked = 1;
            :: else ->
                locked = 0;
            fi;
        }

        if
        :: locked == 1 ->

            if
            /* Only update if the values are the same */
            /* Go back to the start otherwise (i.e. low priority) */
            :: x1 == d1 && x2 == d2 ->

                counter = counter + 1;

                /* Added modulus to prevent overflow */
                c = (c + 1) % 256;

                /* This must be odd here */
                assert(c % 2 == 1);

                /* Check we are incrementing the current value */
                incrementData(d1, d2);
                assert(x1 == d1);
                assert(x2 == d2);

                x1 = (d1 + 1) % 256;
                x2 = (d2 + 1) % 256;
                c = (c + 1) % 256;

                counter = counter - 1;
            :: else
            fi;

            /* Always signal */
            signal(s);
        :: else
        fi;
    od;
}
