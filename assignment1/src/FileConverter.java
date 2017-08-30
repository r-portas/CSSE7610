/**
 * FileConverter
 *
 * Entrypoint for the file converter process
 *
 * @author Roy Portas - 43560846
 */

import java.lang.Thread;
import java.io.IOException;

/**
 * Reads from the file and outputs to the buffer
 */
class ReaderThread extends Thread {

    private CircularBuffer buffer;
    private A1Reader reader;
    private volatile char letter;

    /**
     * Starts a reader thread
     *
     * @param b         The circular buffer
     * @param filename  The filename of the in file
     */
    public ReaderThread(CircularBuffer b, String filename) {
        buffer = b;

        try {
            reader = new A1Reader(filename);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Runs the thread
     */
    public void run() {
        while (true) {
            int c = reader.read();

            if (c == -1) {
                // We propagate the null character through the threads
                // to tell them to exit when there are no more characters
                // to process
                buffer.addItem('\0');
                break;
            }

            letter = (char) c;
            
            if (letter == '\n') {
                letter = ' ';
            }

            buffer.addItem(letter);
        }
    }
}

/**
 * Reads from one buffer, removes tabs and double spaces
 * then writes to the other buffer
 */
class ParserThread extends Thread {

    private CircularBuffer inBuffer;
    private CircularBuffer outBuffer;
    private volatile boolean foundSpace;
    private volatile char character;

    /**
     * Creates a parser instance
     *
     * @param b1    The inbound buffer
     * @param b2    The outbound buffer
     */
    public ParserThread(CircularBuffer b1, CircularBuffer b2) {
        inBuffer = b1;
        outBuffer = b2;
    }

    public void run() {
        foundSpace = false;

        while (true) {
            character = inBuffer.getItem();
            
            if (character == '\t') {
                character = ' ';
            }

            if (foundSpace && character == ' ') {
                // Don't process
                continue;
            } else if (foundSpace) {
                foundSpace = false;
            } else if (character == ' ') {
                foundSpace = true;
            }

            // Put into outbound buffer
            outBuffer.addItem(character);

            // Exit after sending 0
            if (character == '\0' ) {
                break;
            }
        }
    }
}

/**
 * Reads from the buffer and writes to the file
 */
class WriterThread extends Thread {

    private CircularBuffer buffer;
    private A1Writer writer;
    private volatile char character;
    private volatile int counter;

    public WriterThread(CircularBuffer b, String filename) {
        counter = 0;
        buffer = b;
        try {
            writer = new A1Writer(filename);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void run() {
        while (true) {
            character = buffer.getItem(); 

            if (character == '\0') {
                // Close file and exit
                writer.close();
                break;
            }

            if (counter == 80) {
                counter = 0;
                writer.lineBreak();
            }

            writer.write(character);
            counter++;
        }
    }
}

/**
 * Entrypoint for the program
 */
public class FileConverter {

    public static void main(String[] args) {

        // The source file
        String sourceFile = "resources/source.txt";
        // The output file
        String targetFile = "resources/my-target.txt";

        CircularBuffer c1 = new CircularBuffer(20);
        CircularBuffer c2 = new CircularBuffer(20);

        ReaderThread reader = new ReaderThread(c1, sourceFile);
        ParserThread parser = new ParserThread(c1, c2);
        WriterThread writer = new WriterThread(c2, targetFile);

        reader.start();
        parser.start();
        writer.start();

    }
}
