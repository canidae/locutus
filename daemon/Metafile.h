// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef METAFILE_H
#define METAFILE_H

#include <list>
#include <string>

/* fields */
#define ALBUM "ALBUM"
#define ALBUMARTIST "ALBUMARTIST"
#define ALBUMARTISTSORT "ALBUMARTISTSORT"
#define ARTIST "ARTIST"
#define ARTISTSORT "ARTISTSORT"
#define MUSICBRAINZ_ALBUMARTISTID "MUSICBRAINZ_ALBUMARTISTID"
#define MUSICBRAINZ_ALBUMID "MUSICBRAINZ_ALBUMID"
#define MUSICBRAINZ_ARTISTID "MUSICBRAINZ_ARTISTID"
#define MUSICBRAINZ_TRACKID "MUSICBRAINZ_TRACKID"
#define MUSICIP_PUID "MUSICIP_PUID"
#define TITLE "TITLE"
#define TRACKNUMBER "TRACKNUMBER"
#define DATE "DATE"
#define GENRE "GENRE"
/* id3 crap */
#define ID3_TXXX_ALBUMARTISTSORT "ALBUMARTISTSORT"
#define ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID "MusicBrainz Album Artist Id"
#define ID3_TXXX_MUSICBRAINZ_ALBUMID "MusicBrainz Album Id"
#define ID3_TXXX_MUSICBRAINZ_ARTISTID "MusicBrainz Artist Id"
#define ID3_TXXX_MUSICIP_PUID "MusicIP PUID"
#define ID3_UFID_MUSICBRAINZ_TRACKID "http://musicbrainz.org"
/* ape crap */
#define APEALBUM "Album"
#define APEALBUMARTIST "Album Artist"
#define APEALBUMARTISTSORT "ALBUMARTISTSORT"
#define APEARTIST "Artist"
#define APEARTISTSORT "ARTISTSORT"
#define APEMUSICBRAINZ_ALBUMARTISTID "MUSICBRAINZ_ALBUMARTISTID"
#define APEMUSICBRAINZ_ALBUMID "MUSICBRAINZ_ALBUMID"
#define APEMUSICBRAINZ_ARTISTID "MUSICBRAINZ_ARTISTID"
#define APEMUSICBRAINZ_TRACKID "MUSICBRAINZ_TRACKID"
#define APEMUSICIP_PUID "MUSICIP_PUID"
#define APETITLE "Title"
#define APETRACKNUMBER "Track"
#define APEDATE "Year"
#define APEGENRE "Genre"

namespace TagLib {
	namespace APE {
		class Tag;
	}
	namespace Ogg {
		class XiphComment;
	}
	namespace ID3v1 {
		class Tag;
	}
	namespace ID3v2 {
		class Tag;
	}
	class AudioProperties;
}
class Track;

class Metafile {
	public:
		bool duplicate;
		bool force_save;
		bool matched;
		bool meta_lookup;
		bool metadata_updated;
		bool pinned;
		int bitrate;
		int channels;
		int duration;
		int samplerate;
		std::string album;
		std::string albumartist;
		std::string albumartistsort;
		std::string artist;
		std::string artistsort;
		std::string filename;
		std::string genre;
		std::string musicbrainz_albumartistid;
		std::string musicbrainz_albumid;
		std::string musicbrainz_artistid;
		std::string musicbrainz_trackid;
		std::string puid;
		std::string released;
		std::string title;
		std::string tracknumber;

		Metafile(const std::string &filename);
		~Metafile();

		void clearValues();
		std::string getBaseNameWithoutExtension() const;
		std::string getGroup() const;
		const std::list<std::string> &getValues(double combine_threshold);
		bool readFromFile();
		bool saveMetadata();
		bool setMetadata(const Track &track);

	private:
		std::list<std::string> values;

		void readAudioProperties(const TagLib::AudioProperties *ap);
		void readCrapTags(const TagLib::APE::Tag *ape, const TagLib::ID3v2::Tag *id3v2, const TagLib::ID3v1::Tag *id3v1);
		void readXiphComment(const TagLib::Ogg::XiphComment *tag);
		void saveAPETag(TagLib::APE::Tag *tag);
		void saveID3v2Tag(TagLib::ID3v2::Tag *tag);
		void saveXiphComment(TagLib::Ogg::XiphComment *tag);
};
#endif
