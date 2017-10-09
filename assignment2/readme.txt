# General Approach

The monitor was implemented as a class, with every method being declared as synchronised.
The `isAvailable` boolean is used to control access to writing to the variables.
Once a monitor method finishes running, it calls `notifyAll` to wake all the
other threads.

