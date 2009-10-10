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
public class Album {

	private int albumID;
	private String title;
	private int tracks;
	private int filesCompared;
	private int tracksCompared;
	private int mbidsMatched;
	private double maxScore;
	private double avgScore;
	private double minScore;

	public Album(ResultSet rs) throws SQLException {
		albumID = rs.getInt("album_id");
		title = rs.getString("album");
		tracks = rs.getInt("tracks");
		filesCompared = rs.getInt("files_compared");
		tracksCompared = rs.getInt("tracks_compared");
		mbidsMatched = rs.getInt("mbids_matched");
		maxScore = rs.getDouble("max_score");
		avgScore = rs.getDouble("avg_score");
		minScore = rs.getDouble("min_score");
	}

	@Override
	public String toString() {
		/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
		 * solution? add \u200b which is a zero width character (ie. invisible) */
		return "\u200b" + getTitle() + " (" + getTracks() + "/" + getTracksCompared() + "/" + getMBIDsMatched() + " tracks/compared/mbids, " + getFilesCompared() + " files not matched)";
	}

	/**
	 * @return the albumID
	 */
	public int getAlbumID() {
		return albumID;
	}

	/**
	 * @return the title
	 */
	public String getTitle() {
		return title;
	}

	/**
	 * @param title the title to set
	 */
	public void setTitle(String title) {
		this.title = title;
	}

	/**
	 * @return the tracks
	 */
	public int getTracks() {
		return tracks;
	}

	/**
	 * @return the filesCompared
	 */
	public int getFilesCompared() {
		return filesCompared;
	}

	/**
	 * @return the tracksCompared
	 */
	public int getTracksCompared() {
		return tracksCompared;
	}

	/**
	 * @return the mbidsMatched
	 */
	public int getMBIDsMatched() {
		return mbidsMatched;
	}

	/**
	 * @return the maxScore
	 */
	public double getMaxScore() {
		return maxScore;
	}

	/**
	 * @return the avgScore
	 */
	public double getAvgScore() {
		return avgScore;
	}

	/**
	 * @return the minScore
	 */
	public double getMinScore() {
		return minScore;
	}
}
