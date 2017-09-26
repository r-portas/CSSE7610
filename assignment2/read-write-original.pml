/**
 * read-write.pml
 * @author Roy Portas - 43560846
 *
 */ 

byte c = 0;
byte x1 = 0;
byte x2 = 0;
byte item = 0;

inline use(d1, d2) {
    printf("Read (%d, %d)\n", d1, d2);
}

inline get() {
    item = (item+1) % 255;
}

active proctype reader () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 

        do
        :: true -> 
            
            do
            :: true -> 
                c0 = c;
                if 
                :: (c0 == 0) -> break
                fi;
            od;

            d1 = x1;
            d2 = x2;

            if 
            :: (c0 == c) -> break
            fi;
        od;

        use(d1, d2);

    od;
}

active proctype writer () {
    byte c0 = 0;
    byte d1 = 0;
    byte d2 = 0;
    do
    :: true -> 

        do
        :: c == 0 -> break
        od;

        c = c + 1;

        get();
        d1 = item;
        get();
        d2 = item;

        x1 = d1;
        x2 = d2;

        c = c - 1;

    od;
}
