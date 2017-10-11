/**
 *  Assignment 2
 *  @author Roy Portas - 43560846
 */
import java.lang.Thread;
import java.util.Random;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class Monitor {
    /* The number of writers */
    private int writers;

    /* The number of incrementers */
    private int incrementers;

    private ReentrantLock lock = new ReentrantLock();
    private Condition canWrite = lock.newCondition();
    private Condition canIncrement = lock.newCondition();

    public void startWrite() {
        lock.lock();
        try {
            if (writers != 0 || incrementers != 0) {
                // System.out.println(":: Writer waiting: " + writers + " " + incrementers);
                canWrite.await();
            }
            // System.out.println(":: Writer continued");
            writers++;
        } catch (Exception e) {
            System.err.println(e);
        } finally {
            lock.unlock();
        }
    }

    public void endWrite() {
        lock.lock();
        try {
            if (lock.hasWaiters(canWrite)) {
                // Always give writers precendence
                canWrite.signal();
                // System.out.println(":: Signalling writer");
            } else if (lock.hasWaiters(canIncrement)) {
                canIncrement.signal();
                // System.out.println(":: Signalling incrementer");
            }
            writers--;
        } catch (Exception e) {
            System.err.println(e);
        } finally {
            lock.unlock();
        }
    }

    public void startIncrement() {
        lock.lock();
        try {
            if (writers != 0 || incrementers != 0) {
                // System.out.println(":: Incrementer waiting");
                canIncrement.await();
            }
            // System.out.println(":: Incrementer continued");
            incrementers++;
        } catch (Exception e) {
            System.err.println(e);
        } finally {
            lock.unlock();
        }
    }

    public void endIncrement() {
        lock.lock();
        try {
            if (lock.hasWaiters(canWrite)) {
                // Always give writers precendence
                canWrite.signal();
                // System.out.println(":: Signalling writer");
            } else if (lock.hasWaiters(canIncrement)) {
                canIncrement.signal();
                // System.out.println(":: Signalling incrementer");
            }
            incrementers--;
        } catch (Exception e) {
            System.err.println(e);
            System.err.println(e.getMessage());
        } finally {
            lock.unlock();
        }
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

    public Reader(int id, Shared s) {
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
                    do {
                        c0 = shared.c;

                        Thread.yield();
                    } while (c0 % 2 != 0);
                    
                    d1 = shared.x1;
                    d2 = shared.x2;
                    Thread.yield();
                } while (c0 != shared.c);

                A2Event.readData(id, shared.x1, shared.x2);

                if (c0 == 20) {
                    return;
                }

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
                // Test to see if a writer has updated the variables
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

            // simulate the get
            d1 = shared.x1 + 2;
            d2 = shared.x1 + 2;

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
