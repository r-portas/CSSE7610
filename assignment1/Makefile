JC = javac
JAVA_CLASSES = $(wildcard src/*.java)
OUTPUT_DIR = bin

all: .class

.class:
	$(JC) -d $(OUTPUT_DIR) $(JAVA_CLASSES)

clean:
	rm bin/*

run: .class
	java -cp bin FileConverter

dist:
	mkdir -p dist
	cp $(JAVA_CLASSES) dist/
