CXX = g++
RM = rm -f
CXXFLAGS = -O0 -Wall -g -I/usr/include/postgresql -I/usr/include/ffmpeg `taglib-config --cflags`
LDFLAGS = -lccgnu2 -lccext2 -lpq `taglib-config --libs`
OBJECTS = Album.o Artist.o Audioscrobbler.o Database.o Debug.o FileNamer.o Levenshtein.o Locutus.o Match.o Matcher.o Metafile.o Metatrack.o MusicBrainz.o PostgreSQL.o Track.o WebService.o

locutus: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o locutus

Album.o: Album.h Album.cpp
Artist.o: Artist.h Artist.cpp
Audioscrobbler.o: Audioscrobbler.h Audioscrobbler.cpp
Database.o: Database.h Database.cpp
Debug.o: Debug.h Debug.cpp
FileNamer.o: FileNamer.h FileNamer.cpp
Levenshtein.o: Levenshtein.h Levenshtein.cpp
Locutus.o: Locutus.h Locutus.cpp
Match.o: Match.h Match.cpp
Matcher.o: Matcher.h Matcher.cpp
Metafile.o: Metafile.h Metafile.cpp
Metatrack.o: Metatrack.h Metatrack.cpp
MusicBrainz.o: MusicBrainz.h MusicBrainz.cpp
PostgreSQL.o: PostgreSQL.h PostgreSQL.cpp
#PUIDGenerator.o: PUIDGenerator.h PUIDGenerator.cpp
Track.o: Track.h Track.cpp
WebService.o: WebService.h WebService.cpp

.PHONY: clean
clean:
	$(RM) *.o *.gch locutus
