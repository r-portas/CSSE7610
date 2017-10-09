# General Approach

The monitor was implemented as a class, with every method being declared as synchronised.
The `isAvailable` boolean is used to control access to writing to the variables.
Once a monitor method finishes running, it calls `notifyAll` to wake all the
other threads.

The Shared class is used to share the variables and monitor between each thread.
The Reader, Writer and Incrementer classes are implemented as java threads.

The Main class spins up 5 threads of each and then waits for all the readers to yield.
