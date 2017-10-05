import java.lang.Thread;
import java.util.concurrent.Semaphore;

class Shared {
    public int c = 0;
    public int x1 = 0;
    public int x2 = 0;
    public int waitingWriters = 0;

    public Semaphore sem;

    public Shared() {
        // A binary semaphore
        sem = new Semaphore(1);
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
            do {
                do {
                    c0 = shared.c;
                } while (c0 % 2 != 0);
                
                d1 = shared.x1;
                d2 = shared.x2;
            } while (c0 != shared.c);

            A2Event.readData(id, shared.x1, shared.x2);
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
        while (true) {
            try {
                shared.waitingWriters++;
                shared.sem.acquire();

                // Figure out how to get the values
                d1 = shared.x1 + 1;
                d2 = shared.x1 + 1;

                shared.x1 = d1;
                shared.x2 = d2;
                A2Event.writeData(id, shared.x1, shared.x2);

                shared.sem.release();
                shared.waitingWriters--;
            } catch (InterruptedException e) {
                System.err.print(e);
            }
        }
    }
}

class Main {
    public static void main(String[] args) {
        Shared s = new Shared();
        
        Reader r1 = new Reader(1, s);
        r1.start();

        Writer w1 = new Writer(1, s);
        w1.start();
    }
}
