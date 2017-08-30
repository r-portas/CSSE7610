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

/* Count the number of processes in critical sections */
byte critical = 0;

bool PinCS = false;
bool QinCS = false;
ltl nostarve {[]<> PinCS && []<> QinCS}

active proctype p () {
    byte d;
    do
    :: true -> 
        getItem();

        out != (in + 1) % N;

        /* Check for starvation */
        PinCS = true;

        /* Lemma 2 of proof */
        assert(out != (in + 1) % N);

        critical++;
        /* Proof */
        if
        :: (in != out) -> assert(critical <= 1)
        :: else
        fi;
        buffer[in] = counter;
        in = (in + 1) % N
        critical--;

        PinCS = false;

    od;
}

active proctype q () {
    byte d;
    do
    :: true -> 

        in != out;

        /* Check for starvation */
        PinCS = true;

        /* Lemma 1 of proof */
        assert(in != out);

        critical++;
        /* Proof 
        if
        :: (in != out) -> assert(critical <= 1)
        fi;*/
        d = buffer[out];
        out = (out + 1) % N
        critical--;

        PinCS = false;
        useItem(d);
    od;
}

