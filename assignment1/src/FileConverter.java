/**
 * FileConverter
 *
 * Entrypoint for the file converter process
 *
 * @author Roy Portas - 43560846
 */

import java.lang.Thread;

class ReaderThread extends Thread {

    private CircularBuffer buffer;

    public ReaderThread(CircularBuffer b) {
        buffer = b;
    }

    public void run() {
    }
}

class WriterThread extends Thread {

    private CircularBuffer buffer;

    public WriterThread(CircularBuffer b) {
        buffer = b;
    }

    public void run() {
    }
}

class ParserThread extends Thread {

    private CircularBuffer buffer;

    public ParserThread(CircularBuffer b) {
        buffer = b;
    }

    public void run() {
    }
}

public class FileConverter {
    
    private static A1Reader reader;
    private A1Writer writer;

    private CircularBuffer c1 = new CircularBuffer(20);
    private CircularBuffer c2 = new CircularBuffer(20);

    public static void main(String[] args) {

        try {
            reader = new A1Reader("resources/source.txt");
        } catch (Exception e) {
            e.printStackTrace();
        }

        CircularBuffer b = new CircularBuffer(20);
        b.addItem('a');
        b.addItem('b');

        System.out.println(b.getItem());
        System.out.println(b.getItem());
    }
}
