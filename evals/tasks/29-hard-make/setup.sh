mkdir -p src include
printf '#define GREETING "hello v1"\n' > include/config.h
printf '#define SCALE 1\nint util_add(int a, int b);\n' > include/util.h
printf '#include <stdio.h>\n#include "config.h"\n#include "util.h"\nint main(void){ printf("%%s %%d\\n", GREETING, util_add(2, 3)); return 0; }\n' > src/main.c
printf '#include "util.h"\nint util_add(int a, int b){ return (a + b) * SCALE; }\n' > src/util.c
cat > Makefile <<'MK'
CC=gcc
CFLAGS=-O2 -Iinclude
OBJ=build/main.o build/util.o

app: $(OBJ)
	$(CC) -o app $(OBJ)

build/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f app
MK
