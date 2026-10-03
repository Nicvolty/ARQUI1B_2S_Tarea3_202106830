# Variables
AS = aarch64-linux-gnu-as
LD = aarch64-linux-gnu-ld
QEMU = qemu-aarch64
TARGET = programa
OBJS = programa.o

# Declaramos las metas que no generan archivos con su mismo nombre
.PHONY: all assemble link qemu clean

# Regla por defecto (si solo ejecutas 'make')
all: link

# 1. 'make assemble' -> Ensambla programa.s a programa.o
assemble: $(OBJS)

$(OBJS): programa.s bubbleSort.s
	$(AS) programa.s -o $(OBJS)

# 2. 'make link' -> Depende de que exista el .o y genera el ejecutable
link: assemble $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(OBJS) -o $(TARGET)

# 3. 'make qemu' -> Depende de que esté vinculado y lo ejecuta
qemu: link
	$(QEMU) ./$(TARGET)

# 4. 'make clean' -> Borra los archivos generados
clean:
	rm -f $(OBJS) $(TARGET)