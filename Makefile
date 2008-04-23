CXX = g++
RM = rm -f
CXXFLAGS = -O0 -Wall -g -I/usr/include/postgresql `taglib-config --cflags`
LDFLAGS = -lccgnu2 -lccext2 -pthread -lpq `taglib-config --libs`
OBJECTS = Database.o FileMetadata.o FileReader.o Levenshtein.o Locutus.o Metadata.o WebService.o

locutus: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o locutus

Database.o: Database.h Database.cpp
FileMetadata.o: FileMetadata.h FileMetadata.cpp
FileReader.o: FileReader.h FileReader.cpp
Levenshtein.o: Levenshtein.h Levenshtein.cpp
Locutus.o: Locutus.h Locutus.cpp
Metadata.o: Metadata.h Metadata.cpp
WebService.o: WebService.h WebService.cpp

.PHONY: clean
clean:
	$(RM) *.o *.gch locutus
