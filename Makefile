TARGET = hello-asm.gb

$(TARGET): main.asm
	rgbasm -o hello.o main.asm
	rgblink -o $(TARGET) hello.o
	rgbfix -v -p 0 $(TARGET)

run:
	java -jar ~/Emulicious/Emulicious.jar $(TARGET)

clean:
	rm -f $(TARGET)

br:
	rgbasm -o hello.o main.asm
	rgblink -o $(TARGET) hello.o
	rgbfix -v -p 0 $(TARGET)
	java -jar ~/Emulicious/Emulicious.jar $(TARGET)
