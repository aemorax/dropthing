SOURCE_FILES = $(shell find src/ -type f -name '*')

all: bin/game.js

bin/game.js: $(SOURCE_FILES)
	haxe client.hxml
	haxe server.hxml

clean:
	rm -f bin/server.py
	rm -f bin/game.js
