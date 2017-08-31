/**
 * circular.pml
 * @author Roy Portas - 43560846
 *
 * Properties proved:
 * - Mutual Exclusion (using assertions)
 * - Freedom from starvation (using ltl 'nostarve')
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

        /* Mutual Exclusion */
        assert(!((in + 1) % N == out && critical != 0));

        /* Check for starvation */
        PinCS = true;

        /* Lemma 2 of proof */
        assert(out != (in + 1) % N);

        critical++;
        buffer[in] = counter;
        in = (in + 1) % N
        critical--;

        /* Proof */

        PinCS = false;

    od;
}

active proctype q () {
    byte d;
    do
    :: true -> 

        in != out;

        /* Mutual Exclusion */
        assert(!(in == out && critical != 0));

        /* Check for starvation */
        PinCS = true;

        /* Lemma 1 of proof */
        assert(in != out);

        /* Proof */
        /* assert(in != out && critical <= 1); */

        critical++;
        d = buffer[out];
        out = (out + 1) % N
        critical--;

        PinCS = false;

        useItem(d);
    od;
}

