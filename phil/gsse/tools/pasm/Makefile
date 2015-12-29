CC = gcc

PREFIX=/usr/local/bin

default::pasm

FILES = pasm.c pasmpp.c pasmexp.c pasmop.c pasmdot.c pasmstruct.c pasmmacro.c

pasm: $(FILES)
	$(CC) -Wall -D_UNIX_ -o pasm $(FILES)

install: pasm
	cp pasm $(PREFIX)/

clean:
	rm -f pasm
