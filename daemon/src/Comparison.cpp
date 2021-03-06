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

#include "Comparison.h"

using namespace std;

Comparison::Comparison(Metafile* metafile, Track* track, bool mbid_match, double score) : metafile(metafile), track(track), mbid_match(mbid_match), score(score), total_score(score * (mbid_match ? 3 : 1)) {
}
