/**
 * circular.pml
 * @author Roy Portas - 43560846
 */


#define N 10

byte buffer[N];

byte in = 0;
byte out = 0;

// Keeps track of the current number of critical sections entered
byte critical = 0;

// Used to test functionality
byte counter = 0;

inline useItem(d) {
    printf("Got %d\n", d);
}

inline getItem() {
    counter = (counter+1) % 255;
}

// ltl mutex {[] (critical <= 1)}
#define mutex [] (critical <= 1)

active proctype p () {
    byte d;
    do
    :: true -> 
        // Simulates get item
        getItem();

        out != (in + 1) % N;
            // Increment the critical counter when entering the critical section
            critical++;
            buffer[in] = counter;
            // Decrement the critical counter when exiting the critical section
            critical--;

            in = (in + 1) % N
    od;
}

active proctype q () {
    byte d;
    do
    :: true -> 
        in != out;
            critical++;
            d = buffer[out];
            critical--;

            out = (out + 1) % N
            useItem(d);
    od;
}

