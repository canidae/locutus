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

#include "Metatrack.h"

using namespace std;

Metatrack::Metatrack(int duration, int tracknumber, const string& album_mbid, const string& album_title, const string& artist_mbid, const string& artist_name, const string& track_mbid, const string& track_title) : duration(duration), tracknumber(tracknumber), album_mbid(album_mbid), album_title(album_title), artist_mbid(artist_mbid), artist_name(artist_name), track_mbid(track_mbid), track_title(track_title) {
}
