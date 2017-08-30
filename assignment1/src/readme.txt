# Readme

## How to Run

There is an included makefile, just run `make run` and it will compile the
code and run the application. The 'resources' folder contains the source
and target files, once the program is ran a 'my-target.txt' file will
be created, which can be diffed against the 'target.txt' file.

## Approach

The circular buffer was implemented as per the first question, with while loops
simulating the awaits in the algorithm. This works since the buffer is being
accessed by multiple threads simultaneously so eventually the while condition
will become true.

The three threads are implemented by extending the Thread class. They share
2 circular buffers, one between the Reader and Parser thread and the other
between the Parser and Writer threads.


The ReaderThread creates a A1Reader instance and reads the file, passing 
each character into the buffer. Once the EOF is received (-1), it is
added to the circular buffer before the thread exits.

The ParserThread reads from one circular buffer, checks for tab and extra
space characters, removes them then puts the character into the other buffer
for processing by the WriterThread. Once a EOF is received (-1), it is
added to the circular buffer before the thread exits.

The WriterThread reads from the buffer and writes to the file. When a EOF
character (-1) is read, the thread exits.
