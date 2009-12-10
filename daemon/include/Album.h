// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

#ifndef ALBUM_H
#define ALBUM_H

#include <string>
#include <vector>

class Artist;
class Track;

class Album {
public:
	Artist *artist;
	std::string mbid;
	std::string released;
	std::string title;
	std::string type;
	std::vector<Track *> tracks;

	explicit Album(const std::string &mbid = "");
	~Album();
};
#endif
