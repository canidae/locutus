CXX = g++
RM = rm -f
CXXFLAGS = -O0 -Wall -g -I/usr/include/postgresql -I/usr/include/ffmpeg `taglib-config --cflags`
LDFLAGS = -lccgnu2 -lccext2 -lpq -lavcodec `taglib-config --libs`
OBJECTS = Album.o Artist.o Database.o FileReader.o Levenshtein.o Locutus.o Metafile.o Metatrack.o PUIDGenerator.o Settings.o Track.o Matcher.o WebService.o XMLNode.o

locutus: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o locutus

Album.o: Album.h Album.cpp
Artist.o: Artist.h Artist.cpp
Database.o: Database.h Database.cpp
FileReader.o: FileReader.h FileReader.cpp
Levenshtein.o: Levenshtein.h Levenshtein.cpp
Locutus.o: Locutus.h Locutus.cpp
Metafile.o: Metafile.h Metafile.cpp
Metatrack.o: Metatrack.h Metatrack.cpp
PUIDGenerator.o: PUIDGenerator.h PUIDGenerator.cpp
Settings.o: Settings.h Settings.cpp
Track.o: Track.h Track.cpp
Matcher.o: Matcher.h Matcher.cpp
WebService.o: WebService.h WebService.cpp
XMLNode.o: XMLNode.h XMLNode.cpp

.PHONY: clean
clean:
	$(RM) *.o *.gch locutus
