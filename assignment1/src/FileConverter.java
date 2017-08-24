/**
 * FileConverter
 *
 * Entrypoint for the file converter process
 *
 * @author Roy Portas - 43560846
 */

public class FileConverter {
    
    private static A1Reader reader;
    private A1Writer writer;

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
