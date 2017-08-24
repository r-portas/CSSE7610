import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * DO NOT MODIFY THIS CLASS
 * 
 * This class is used to write single characters and line breaks to a file whose
 * name is passed as a parameter to its constructor.
 */
public class A1Writer {

	PrintWriter pw; // an object for writing characters to a byte stream

	/**
	 * Construct a file writer for writing to a specified file.
	 * 
	 * @param fileName	 the name of the file
	 */
	public A1Writer(String fileName) throws IOException {
		pw = new PrintWriter(new FileOutputStream(new File(fileName)));
	}

	/**
	 * Write a single character to the file.
	 * 
	 * @param d	   the character
	 */
	public void write(char d) {
		pw.write(d);
	}

	/**
	 * Write a line break to the file.
	 */
	public void lineBreak() {
		pw.write(System.getProperty("line.separator"));
	}

	/**
	 * Close the file writer. This must be done when writing to the file is
	 * finished to ensure any buffered characters are flushed.
	 */
	public void close() {
		pw.close();
	}
}
