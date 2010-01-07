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

#ifndef TRACK_H
#define TRACK_H

#include <string>
#include "Metatrack.h"

class Album;
class Artist;

class Track {
public:
	Album* album;
	Artist* artist;
	int duration;
	int tracknumber;
	std::string mbid;
	std::string title;

	explicit Track(Album* album);
	~Track();

	Metatrack getAsMetatrack() const;
};
#endif
