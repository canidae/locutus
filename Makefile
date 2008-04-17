CXX = g++
RM = rm -f
CXXFLAGS = -O0 -Wall -g# -I/usr/include/postgresql `taglib-config --cflags`
LDFLAGS = -lccgnu2 -lccext2 #-lpq -lpqxx `taglib-config --libs`
OBJECTS = Locutus.o Matcher.o WebService.o

locutus: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o locutus

Locutus.o: Locutus.h Locutus.cpp
Matcher.o: Matcher.h Matcher.cpp
WebService.o: WebService.h WebService.cpp

.PHONY: clean
clean:
	$(RM) *.o *.gch locutus
