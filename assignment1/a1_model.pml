/**
 * circular.pml
 * @author Roy Portas - 43560846
 */ 

/* Buffer size */
#define N 10

byte buffer[N];

byte in = 0;
byte out = 0;

/* Used to test functionality */
byte counter = 0;

/* Simulates using an item */
inline useItem(d) {
    printf("Got %d\n", d);
}

/* Simulates getting an item */
inline getItem() {
    counter = (counter+1) % 255;
}

bool PinCS = false;
bool QinCS = false;
ltl nostarve {[]<> PinCS && []<> QinCS}

active proctype p () {
    byte d;
    do
    :: true -> 
        getItem();

        /* Check for starvation */
        PinCS = true;
        PinCS = false;
        out != (in + 1) % N;

        buffer[in] = counter;

        in = (in + 1) % N
    od;
}

active proctype q () {
    byte d;
    do
    :: true -> 

        in != out;

        /* Check for starvation */
        PinCS = true;
        PinCS = false;

        /* We check mutual exclusion by ensuring in != out,
        thus cannot be reading the same thing we are writing */
        assert(in != out);
        d = buffer[out];

        out = (out + 1) % N
        useItem(d);
    od;
}

