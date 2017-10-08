import java.lang.Thread;
import java.util.Random;

class Monitor {
    /* The number of writers waiting for the lock */
    private int writersWaiting;
    /* The lock on the variables x1 and x2 */
    private boolean isAvailable;

    public synchronized void startWrite() {
        writersWaiting++;

        while (isAvailable == false) {
            try {
                wait();
            } catch (InterruptedException e) {}
        }
        isAvailable = false;
        writersWaiting--;
        notifyAll();
    }

    public synchronized void endWrite() {
        isAvailable = true;
        notifyAll();
    }

    public synchronized void startIncrement() {
        if (writersWaiting == 0) {
            while (isAvailable == false) {
                try {
                    wait();
                } catch (InterruptedException e) {}
            }

            isAvailable = false;
            notifyAll();
        }
        notifyAll();
    }

    public synchronized void endIncrement() {
        isAvailable = true;
        notifyAll();
    }
}

class Shared {
    public int c = 0;
    public int x1 = 0;
    public int x2 = 0;

    public Monitor mon;
    public Random rand;

    public Shared() {
        // The monitor;
        mon = new Monitor();

        // Specify a seed for consistency
        rand = new Random(1);
    }
}

class MyThread extends Thread {
    int id;
    Shared shared;

    public MyThread(int id, Shared s) {
        this.id = id;
        this.shared = s;
    }
}

class Reader extends MyThread {
    int c0;
    int d1;
    int d2;

    int lastRead;

    public Reader(int id, Shared s) {
        super(id, s);
        c0 = 0;
        d1 = 0;
        d2 = 0;
        lastRead = -1;
    }

    public void run() {
        while (true) {
            try {
                // Wait a random amount of time
                Thread.sleep(shared.rand.nextInt(10));

                do {
                    do {
                        c0 = shared.c;
                        Thread.yield();
                    } while (c0 % 2 != 0);
                    
                    d1 = shared.x1;
                    d2 = shared.x2;
                    Thread.yield();
                } while (c0 != shared.c);

                if (lastRead == c0) {
                    // End the reader
                    break;
                }
                lastRead = c0;

                A2Event.readData(id, shared.x1, shared.x2);
                Thread.yield();

            } catch (InterruptedException e) {
                System.err.print(e);
            }
        }
    }
}

class Incrementer extends MyThread {
    int c0;
    int d1;
    int d2;

    public Incrementer(int id, Shared s) {
        super(id, s);
        c0 = 0;
        d1 = 0;
        d2 = 0;
    }

    public void run() {
        while (true) {
            try {
                // Wait a random amount of time
                Thread.sleep(shared.rand.nextInt(10));

                do {
                    c0 = shared.c;
                    Thread.yield();
                } while (c0 % 2 != 0);
                
                d1 = shared.x1;
                d2 = shared.x2;

                shared.mon.startIncrement();
                if (c0 == shared.c) {
                    shared.c++;

                    shared.x1 = d1 + 1;
                    shared.x2 = d2 + 1;
                    A2Event.incrementData(id, shared.x1, shared.x2);

                    shared.c++;
                    shared.mon.endIncrement();
                    break;
                }
                shared.mon.endIncrement();
                Thread.yield();

            } catch (InterruptedException e) {
                System.err.print(e);
            }
        }
    }
}

class Writer extends MyThread {
    int d1;
    int d2;
    
    public Writer(int id, Shared s) {
        super(id, s);
        d1 = 0;
        d2 = 0;
    }

    public void run() {
        try {
            // Wait a random amount of time
            Thread.sleep(shared.rand.nextInt(10));

            shared.mon.startWrite();
            shared.c++;

            // Figure out how to get the values
            d1 = shared.x1 + 1;
            d2 = shared.x1 + 1;

            shared.x1 = d1;
            shared.x2 = d2;
            A2Event.writeData(id, shared.x1, shared.x2);

            shared.c++;
            shared.mon.endWrite();
            Thread.yield();
        } catch (InterruptedException e) {
            System.err.print(e);
        }
    }
}

class Main {
    public static void main(String[] args) {
        Shared s = new Shared();

        int numReaders = 5;
        int numWriters = 5;
        int numIncrementers = 5;
        
        Reader[] readers = new Reader[numReaders];
        for (int i = 0; i < numReaders; i++) {
            readers[i] = new Reader(i, s);
            readers[i].start();
        }

        Writer[] writers = new Writer[numWriters];
        for (int i = 0; i < numWriters; i++) {
            writers[i] = new Writer(i, s);
            writers[i].start();
        }

        Incrementer[] incrementers = new Incrementer[numIncrementers];
        for (int i = 0; i < numIncrementers; i++) {
            incrementers[i] = new Incrementer(i, s);
            incrementers[i].start();
        }

        for (int i = 0; i < numReaders; i++) {
            try {
                readers[i].join();
            } catch (InterruptedException e) {}
        }
    
        A2Event.terminateReadWrite();
    }
}
