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

/* Stores which write operation last wrote to x1 and x2 */
byte x1_occurrence = 0;
byte x2_occurrence = 0;

/* Q2 a */
#define partA (x1_occurrence == x2_occurrence)

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
        d1 = x1;
        d2 = x2;

        atomic {
            if 
            :: (x1 == d1 && x2 == d2) -> 
                /* The values have not updated, so break */
                counter = counter + 1;
                readData(d1, d2);

                /* Q2 a */
                assert(x1_occurrence == x2_occurrence)

                counter = counter - 1;
            :: else
            fi;
        }

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

                    /* Q2 a */
                    assert(x1_occurrence == x2_occurrence)

                    // Simulate the get
                    get();
                    x1 = item;
                    /* Increment the x1 occurrence */
                    x1_occurrence = (x1_occurrence + 1) % 255;

                    get();
                    x2 = item;
                    /* Increment the x2 occurrence */
                    x2_occurrence = (x2_occurrence + 1) % 255;

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

                    /* Q2 part b */
                    assert(x1 == d1);
                    assert(x2 == d2);

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
