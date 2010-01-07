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

#ifndef METATRACK_H
#define METATRACK_H

#include <string>

class Metatrack {
public:
	int duration;
	int tracknumber;
	std::string album_mbid;
	std::string album_title;
	std::string artist_mbid;
	std::string artist_name;
	std::string track_mbid;
	std::string track_title;

	Metatrack(int duration = 0, int tracknumber = 0, const std::string& album_mbid = "", const std::string& album_title = "", const std::string& artist_mbid = "", const std::string& artist_name = "", const std::string& track_mbid = "", const std::string& track_title = "");
};
#endif
