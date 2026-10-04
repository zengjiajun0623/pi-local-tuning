cat > Makefile <<'MK'
CC=gcc
CFLAGS=-O2 -Iinclude -MMD -MP
OBJ=build/main.o build/util.o

app: $(OBJ)
	$(CC) -o app $(OBJ)

build/%.o: src/%.c | build
	$(CC) $(CFLAGS) -c $< -o $@

build:
	mkdir -p build

clean:
	rm -rf app build

.PHONY: clean
-include $(OBJ:.o=.d)
MK
