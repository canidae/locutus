/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.exent.locutus.data;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author canidae
 */
public class Metafile {

	public static final int NONE = 0;
	public static final int SAVE = 1;
	public static final int DELETE = 2;
	private int fileID;
	private String filename;
	private String album;
	private String albumMBID;
	private String albumArtist;
	private String albumArtistMBID;
	private String albumArtistSortName;
	private String artist;
	private String artistMBID;
	private String artistSortName;
	private String title;
	private String trackMBID;
	private String released;
	private String genre;
	private String group;
	private int tracknumber;
	private int duration;
	private int bitrate;
	private int channels;
	private int samplerate;
	private int trackID;
	private int compareTrackID;
	private double score;
	private boolean mbidMatch;
	private boolean duplicate;
	private boolean modified;
	private boolean pinned;
	private int status;

	public Metafile(ResultSet rs) throws SQLException {
		fileID = rs.getInt("file_file_id");
		filename = rs.getString("file_filename");
		album = rs.getString("file_album");
		albumMBID = rs.getString("file_musicbrainz_albumid");
		albumArtist = rs.getString("file_albumartist");
		albumArtistMBID = rs.getString("file_musicbrainz_albumartistid");
		albumArtistSortName = rs.getString("file_albumartistsort");
		artist = rs.getString("file_artist");
		artistMBID = rs.getString("file_musicbrainz_artistid");
		artistSortName = rs.getString("file_artistsort");
		title = rs.getString("file_title");
		trackMBID = rs.getString("file_musicbrainz_trackid");
		released = rs.getString("file_released");
		genre = rs.getString("file_genre");
		group = rs.getString("file_groupname");
		try {
			tracknumber = Integer.parseInt(rs.getString("file_tracknumber"));
		} catch (NumberFormatException e) {
			tracknumber = 0;
		}
		duration = rs.getInt("file_duration");
		bitrate = rs.getInt("file_bitrate");
		channels = rs.getInt("file_channels");
		samplerate = rs.getInt("file_samplerate");
		trackID = rs.getInt("file_track_id");
		compareTrackID = rs.getInt("track_track_id");
		score = rs.getDouble("comparison_score");
		mbidMatch = rs.getBoolean("comparison_mbid_match");
		duplicate = rs.getBoolean("file_duplicate");
		modified = rs.getBoolean("file_user_changed");
		pinned = rs.getBoolean("file_pinned");
		status = NONE;
	}

	@Override
	public String toString() {
		/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
		 * solution? add \u200b which is a zero width character (ie. invisible) */
		return "\u200b" + (getTracknumber() > 9 ? getTracknumber() : "0" + getTracknumber()) + " - " + getDuration() + " - " + getAlbumArtist() + " - " + getAlbum() + " - " + getArtist() + " - " + getTitle() + " (" + getFilename() + ")";
	}

	/**
	 * @return the file_id
	 */
	public int getFileID() {
		return fileID;
	}

	/**
	 * @return the filename
	 */
	public String getFilename() {
		return filename;
	}

	/**
	 * @return the album
	 */
	public String getAlbum() {
		return album;
	}

	/**
	 * @return the album_artist
	 */
	public String getAlbumArtist() {
		return albumArtist;
	}

	/**
	 * @return the artist
	 */
	public String getArtist() {
		return artist;
	}

	/**
	 * @return the title
	 */
	public String getTitle() {
		return title;
	}

	/**
	 * @return the tracknumber
	 */
	public int getTracknumber() {
		return tracknumber;
	}

	/**
	 * @return the duration
	 */
	public int getDuration() {
		return duration;
	}

	/**
	 * @return the file_track_id
	 */
	public int getTrackID() {
		return trackID;
	}

	/**
	 * @return the compare_track_id
	 */
	public int getCompareTrackID() {
		return compareTrackID;
	}

	/**
	 * @return the score
	 */
	public double getScore() {
		return score;
	}

	/**
	 * @return the mbid_match
	 */
	public boolean isMBIDMatch() {
		return mbidMatch;
	}

	/**
	 * @return the status
	 */
	public int getStatus() {
		return status;
	}

	/**
	 * @param status the status to set
	 */
	public void setStatus(int status) {
		this.status = status;
	}

	/**
	 * @return the albumArtistMBID
	 */
	public String getAlbumArtistMBID() {
		return albumArtistMBID;
	}

	/**
	 * @return the albumArtistSortName
	 */
	public String getAlbumArtistSortName() {
		return albumArtistSortName;
	}

	/**
	 * @return the albumMBID
	 */
	public String getAlbumMBID() {
		return albumMBID;
	}

	/**
	 * @return the artistMBID
	 */
	public String getArtistMBID() {
		return artistMBID;
	}

	/**
	 * @return the artistSortName
	 */
	public String getArtistSortName() {
		return artistSortName;
	}

	/**
	 * @return the bitrate
	 */
	public int getBitrate() {
		return bitrate;
	}

	/**
	 * @return the channels
	 */
	public int getChannels() {
		return channels;
	}

	/**
	 * @return the samplerate
	 */
	public int getSamplerate() {
		return samplerate;
	}

	/**
	 * @return the genre
	 */
	public String getGenre() {
		return genre;
	}

	/**
	 * @return the group
	 */
	public String getGroup() {
		return group;
	}

	/**
	 * @return the trackMBID
	 */
	public String getTrackMBID() {
		return trackMBID;
	}

	/**
	 * @return the released
	 */
	public String getReleased() {
		return released;
	}

	/**
	 * @return the duplicate
	 */
	public boolean isDuplicate() {
		return duplicate;
	}

	/**
	 * @return the modified
	 */
	public boolean isModified() {
		return modified;
	}

	/**
	 * @return the pinned
	 */
	public boolean isPinned() {
		return pinned;
	}
}
