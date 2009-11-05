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
	public static final int SAVE_METADATA = 3;
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

	public Metafile() {
	}

	public void setMatchingData(ResultSet rs) throws SQLException {
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

	public void setUncomparedData(ResultSet rs) throws SQLException {
		fileID = rs.getInt("file_id");
		filename = rs.getString("filename");
		album = rs.getString("album");
		albumMBID = rs.getString("musicbrainz_albumid");
		albumArtist = rs.getString("albumartist");
		albumArtistMBID = rs.getString("musicbrainz_albumartistid");
		albumArtistSortName = rs.getString("albumartistsort");
		artist = rs.getString("artist");
		artistMBID = rs.getString("musicbrainz_artistid");
		artistSortName = rs.getString("artistsort");
		title = rs.getString("title");
		trackMBID = rs.getString("musicbrainz_trackid");
		released = rs.getString("released");
		genre = rs.getString("genre");
		group = rs.getString("groupname");
		try {
			tracknumber = Integer.parseInt(rs.getString("tracknumber"));
		} catch (NumberFormatException e) {
			tracknumber = 0;
		}
		duration = rs.getInt("duration");
		bitrate = rs.getInt("bitrate");
		channels = rs.getInt("channels");
		samplerate = rs.getInt("samplerate");
		trackID = rs.getInt("track_id");
		compareTrackID = rs.getInt("track_id");
		duplicate = rs.getBoolean("duplicate");
		modified = rs.getBoolean("user_changed");
		pinned = rs.getBoolean("pinned");
		status = NONE;
		score = -1.0;
	}

	@Override
	public String toString() {
		/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
		 * solution? add \u200b which is a zero width character (ie. invisible) */
		if (score < 0.0)
			return "\u200b" + getFilename();
		else
			return "\u200b" + (getTracknumber() > 9 ? getTracknumber() : "0" + getTracknumber()) + " - " + getDuration() + " - " + getAlbumArtist() + " - " + getAlbum() + " - " + getArtist() + " - " + getTitle() + " [" + (((int) (1000.0 * score)) / 10.0) + "%]";
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

	/**
	 * @param album the album to set
	 */
	public void setAlbum(String album) {
		this.album = album;
	}

	/**
	 * @param albumMBID the albumMBID to set
	 */
	public void setAlbumMBID(String albumMBID) {
		this.albumMBID = albumMBID;
	}

	/**
	 * @param albumArtist the albumArtist to set
	 */
	public void setAlbumArtist(String albumArtist) {
		this.albumArtist = albumArtist;
	}

	/**
	 * @param albumArtistMBID the albumArtistMBID to set
	 */
	public void setAlbumArtistMBID(String albumArtistMBID) {
		this.albumArtistMBID = albumArtistMBID;
	}

	/**
	 * @param albumArtistSortName the albumArtistSortName to set
	 */
	public void setAlbumArtistSortName(String albumArtistSortName) {
		this.albumArtistSortName = albumArtistSortName;
	}

	/**
	 * @param artist the artist to set
	 */
	public void setArtist(String artist) {
		this.artist = artist;
	}

	/**
	 * @param artistMBID the artistMBID to set
	 */
	public void setArtistMBID(String artistMBID) {
		this.artistMBID = artistMBID;
	}

	/**
	 * @param artistSortName the artistSortName to set
	 */
	public void setArtistSortName(String artistSortName) {
		this.artistSortName = artistSortName;
	}

	/**
	 * @param title the title to set
	 */
	public void setTitle(String title) {
		this.title = title;
	}

	/**
	 * @param trackMBID the trackMBID to set
	 */
	public void setTrackMBID(String trackMBID) {
		this.trackMBID = trackMBID;
	}

	/**
	 * @param released the released to set
	 */
	public void setReleased(String released) {
		this.released = released;
	}

	/**
	 * @param genre the genre to set
	 */
	public void setGenre(String genre) {
		this.genre = genre;
	}

	/**
	 * @param tracknumber the tracknumber to set
	 */
	public void setTracknumber(int tracknumber) {
		this.tracknumber = tracknumber;
	}

	/**
	 * @param pinned the pinned to set
	 */
	public void setPinned(boolean pinned) {
		this.pinned = pinned;
	}
}
