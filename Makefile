CXX = g++
RM = rm -f
CXXFLAGS = -O0 -Wall -g# -I/usr/include/postgresql `taglib-config --cflags`
LDFLAGS = -lccgnu2 -lccext2 -pthread #-lpq -lpqxx `taglib-config --libs`
OBJECTS = FileMetadata.o Levenshtein.o Locutus.o Metadata.o WebService.o

locutus: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o locutus

FileMetadata.o: FileMetadata.h FileMetadata.cpp
Levenshtein.o: Levenshtein.h Levenshtein.cpp
Locutus.o: Locutus.h Locutus.cpp
Metadata.o: Metadata.h Metadata.cpp
WebService.o: WebService.h WebService.cpp

.PHONY: clean
clean:
	$(RM) *.o *.gch locutus
