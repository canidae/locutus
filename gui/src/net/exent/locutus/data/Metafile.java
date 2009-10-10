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
	private String albumArtist;
	private String artist;
	private String title;
	private int tracknumber;
	private int duration;
	private int fileTrackID;
	private int compareTrackID;
	private double score;
	private boolean mbidMatch;
	private int status;

	public Metafile(ResultSet rs) throws SQLException {
		fileID = rs.getInt("file_file_id");
		filename = rs.getString("file_filename");
		album = rs.getString("file_album");
		albumArtist = rs.getString("file_albumartist");
		artist = rs.getString("file_artist");
		title = rs.getString("file_title");
		try {
			tracknumber = Integer.parseInt(rs.getString("file_tracknumber"));
		} catch (NumberFormatException e) {
			tracknumber = 0;
		}
		duration = rs.getInt("file_duration");
		fileTrackID = rs.getInt("file_track_id");
		compareTrackID = rs.getInt("track_track_id");
		score = rs.getDouble("comparison_score");
		mbidMatch = rs.getBoolean("comparison_mbid_match");
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
	public int getFileTrackID() {
		return fileTrackID;
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
}
