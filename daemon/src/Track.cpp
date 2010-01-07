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

#include "Album.h"
#include "Artist.h"
#include "Track.h"

using namespace std;

Track::Track(Album* album) : album(album), artist(new Artist()), duration(0), tracknumber(0), mbid(""), title("") {
}

Track::~Track() {
	delete artist;
}

Metatrack Track::getAsMetatrack() const {
	if (album == NULL || artist == NULL)
		return Metatrack();
	return Metatrack(duration, tracknumber, album->mbid, album->title, artist->mbid, artist->name, mbid, title);
}
