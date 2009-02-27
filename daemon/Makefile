CXX = g++
RM = rm -f
CXXFLAGS = -O0 -Wall -Wextra -g -pg -I/usr/include/postgresql `taglib-config --cflags`
LDFLAGS = -g -pg -lccgnu2 -lccext2 -lpq `taglib-config --libs`
OBJECTS = Album.o Artist.o Audioscrobbler.o Comparison.o Config.o Database.o Debug.o FileNamer.o Levenshtein.o Locutus.o Matcher.o Metafile.o Metatrack.o MusicBrainz.o PostgreSQL.o Track.o WebService.o

locutus: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o locutus

Album.o: Album.h Album.cpp
Artist.o: Artist.h Artist.cpp
Audioscrobbler.o: Audioscrobbler.h Audioscrobbler.cpp
Comparison.o: Comparison.h Comparison.cpp
Config.o: Config.h Config.cpp
Database.o: Database.h Database.cpp
Debug.o: Debug.h Debug.cpp
FileNamer.o: FileNamer.h FileNamer.cpp
Levenshtein.o: Levenshtein.h Levenshtein.cpp
Locutus.o: Locutus.h Locutus.cpp
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
