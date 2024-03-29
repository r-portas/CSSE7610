/**
 * CircularBuffer
 *
 * An implementation of the circular buffer from the assignment
 * sheet
 *
 * @author Roy Portas
 */
public class CircularBuffer {

    private volatile int bufferSize;
    private volatile char[] buffer;

    private volatile int in;
    private volatile int out;

    /**
     * Creates the circular buffer
     * @param size The size of the buffer
     */
    public CircularBuffer(int size) {
        bufferSize = size;
        buffer = new char[bufferSize];

        in = 0;
        out = 0;
    }

    /**
     * Adds an item to the buffer
     *
     * @param item The item to add
     */
    public void addItem(char item) {
        while (out == (in + 1) % bufferSize) {
            // Wait here
        }

        buffer[in] = item;
        in = (in+1) % bufferSize;
    }

    /**
     * Gets an item from the buffer
     *
     * @returns The item
     */
    public char getItem() {
        while (in == out) {
            // Wait here
        }

        char c = buffer[out];
        out = (out+1) % bufferSize;
        return c;
    }
}
