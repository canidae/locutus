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
package net.exent.locutus.data;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author canidae
 */
public class Track {

	private int trackID;
	private String title;
	private int tracknumber;
	private int duration;
	private String artist;
	private String album;
	private String albumArtist;
	private double score;
	private boolean gotMatch;
	private boolean gotFiles;

	public Track(ResultSet rs) throws SQLException {
		trackID = rs.getInt("track_track_id");
		title = rs.getString("track_title");
		tracknumber = rs.getInt("track_tracknumber");
		duration = rs.getInt("track_duration");
		artist = rs.getString("trackartist_name");
		album = rs.getString("album_title");
		albumArtist = rs.getString("albumartist_name");
		score = rs.getDouble("comparison_score");
		gotMatch = (rs.getInt("file_track_id") > 0 && !rs.wasNull());
		gotFiles = (rs.getInt("file_file_id") > 0 && !rs.wasNull());
	}

	@Override
	public String toString() {
		/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
		 * solution? add \u200b which is a zero width character (ie. invisible) */
		return "\u200b" + (getTracknumber() > 9 ? getTracknumber() : "0" + getTracknumber()) + " - " + getDuration() + " - " + getAlbumArtist() + " - " + getAlbum() + " - " + getArtist() + " - " + getTitle();
	}

	/**
	 * @return the trackID
	 */
	public int getTrackID() {
		return trackID;
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
	 * @return the artist
	 */
	public String getArtist() {
		return artist;
	}

	/**
	 * @return the album
	 */
	public String getAlbum() {
		return album;
	}

	/**
	 * @return the albumArtist
	 */
	public String getAlbumArtist() {
		return albumArtist;
	}

	/**
	 * @return the score
	 */
	public double getScore() {
		return score;
	}

	/**
	 * @return the gotMatch
	 */
	public boolean hasGotMatch() {
		return gotMatch;
	}

	/**
	 * @return the gotFiles
	 */
	public boolean hasGotFiles() {
		return gotFiles;
	}
}
