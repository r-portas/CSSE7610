import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

/**
 * DO NOT MODIFY THIS CLASS
 * 
 * This class is used to read single characters from a file whose name is passed
 * as a parameter to its constructor.
 */
public class A1Reader {

	private BufferedReader br; // an object for reading characters from a byte stream

	/**
	 * Construct a file reader for reading from a specified file.
	 * 
	 * @param fileName    the name of the file
	 */
	public A1Reader(String fileName) throws IOException {
		br = new BufferedReader(new FileReader(fileName));
	}

	/**
	 * Read a single character from the file.
	 * 
	 * @return the character or -1 if end-of-file is reached (-1 is also returned if 
	 *         an IOException is caught)
	 */
	public int read() {
		try {
			int i = br.read();
			// ignore '\r' (carriage return) which occurs before '\n' (new line) on Windows operating systems
			if ((char) i == '\r')
				i = br.read();
			return i;
		} catch (IOException e) {
			System.err.println("Exception occurred while reading.");
			return -1;
		}
	}

	/**
	 * Close the file reader. This should be done when reading to the file is
	 * finished to release associated system resources.
	 */
	public void close() {
		try {
			br.close();
		} catch (IOException e) {
			System.err.println("Exception occurred while closing reader.");
		}
	}

}
