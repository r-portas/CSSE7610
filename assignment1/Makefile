JC = javac
JAVA_CLASSES = $(wildcard src/*.java)
OUTPUT_DIR = bin

all: .class

.class:
	mkdir -p bin
	$(JC) -d $(OUTPUT_DIR) $(JAVA_CLASSES)

clean:
	rm bin/*

run: .class
	java -cp bin FileConverter

dist:
	mkdir -p dist
	mkdir -p dist/java
	mkdir -p dist/java/src
	mkdir -p dist/java/resources
	cp $(JAVA_CLASSES) dist/java/src
	cp distMakefile dist/java/Makefile
	cp resources/target.txt dist/java/resources/target.txt
	cp resources/source.txt dist/java/resources/source.txt
	cp src/readme.txt dist/java/readme.txt
	cp report/main.pdf dist/circular.pdf
	cp spin/circular.pml dist/circular.pml

del-dist:
	rm -rfv dist
