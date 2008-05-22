CXX = g++
RM = rm -f
CXXFLAGS = -O0 -Wall -g -I/usr/include/postgresql `taglib-config --cflags`
LDFLAGS = -lccgnu2 -lccext2 -lpq `taglib-config --libs`
OBJECTS = Album.o Artist.o Database.o FileMetadata.o FileMetadataConstants.o FileReader.o Levenshtein.o Locutus.o Metadata.o PUIDGenerator.o Settings.o Track.o WebFetcher.o WebService.o

locutus: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o locutus

Album.o: Album.h Album.cpp
Artist.o: Artist.h Artist.cpp
Database.o: Database.h Database.cpp
FileMetadata.o: FileMetadata.h FileMetadata.cpp
FileMetadataConstants.o: FileMetadataConstants.h FileMetadataConstants.cpp
FileReader.o: FileReader.h FileReader.cpp
Levenshtein.o: Levenshtein.h Levenshtein.cpp
Locutus.o: Locutus.h Locutus.cpp
Metadata.o: Metadata.h Metadata.cpp
PUIDGenerator.o: PUIDGenerator.h PUIDGenerator.cpp
Settings.o: Settings.h Settings.cpp
Track.o: Track.h Track.cpp
WebFetcher.o: WebFetcher.h WebFetcher.cpp
WebService.o: WebService.h WebService.cpp

.PHONY: clean
clean:
	$(RM) *.o *.gch locutus
