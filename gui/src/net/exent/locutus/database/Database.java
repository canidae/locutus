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
package net.exent.locutus.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import net.exent.locutus.data.Metafile;

/**
 *
 * @author canidae
 */
public class Database {

	private static Connection connection;
	private static PreparedStatement deleteComparison;
	private static PreparedStatement deleteMatch;
	private static PreparedStatement matchFile;
	private static PreparedStatement matchingDetails;
	private static PreparedStatement matchingList;
	private static PreparedStatement resetAllSettings;
	private static PreparedStatement resetSetting;
	private static PreparedStatement saveMetadata;
	private static PreparedStatement setSetting;
	private static PreparedStatement settingList;
	private static PreparedStatement status;
	private static PreparedStatement uncompared;

	public static void connectPostgreSQL(String url, String username, String password) throws ClassNotFoundException, SQLException {
		Class.forName("org.postgresql.Driver");
		connection = DriverManager.getConnection(url, username, password);

		/* prepared statements */
		deleteComparison = connection.prepareStatement("DELETE FROM comparison WHERE file_id = ? AND track_id = ?");
		deleteMatch = connection.prepareStatement("UPDATE file SET track_id = NULL, user_changed = true WHERE file_id = ? AND track_id IS NOT NULL");
		matchFile = connection.prepareStatement("UPDATE file SET track_id = ?, user_changed = true WHERE file_id = ?");
		matchingDetails = connection.prepareStatement("SELECT * FROM v_ui_matching_details WHERE album_album_id = ? AND (file_track_id IS NULL OR file_track_id = track_track_id) ORDER BY track_tracknumber ASC, comparison_mbid_match DESC, comparison_score DESC");
		matchingList = connection.prepareStatement("SELECT * FROM v_ui_matching_list WHERE album ILIKE ? ORDER BY tracks_compared * avg_score DESC");
		resetAllSettings = connection.prepareStatement("UPDATE setting SET value = default_value");
		resetSetting = connection.prepareStatement("UPDATE setting SET value = default_value WHERE key = ?");
		saveMetadata = connection.prepareStatement("UPDATE file SET album = ?, albumartist = ?, albumartistsort = ?, artist = ?, artistsort = ?, musicbrainz_albumartistid = ?, musicbrainz_albumid = ?, musicbrainz_artistid = ?, musicbrainz_trackid = ?, title = ?, tracknumber = ?, released = ?, genre = ?, pinned = ?, user_changed = true WHERE file_id = ?");
		setSetting = connection.prepareStatement("UPDATE setting SET value = ? WHERE key = ?");
		settingList = connection.prepareStatement("SELECT * FROM setting");
		status = connection.prepareStatement("SELECT *, EXTRACT(epoch FROM now() - start) AS runtime FROM locutus");
		uncompared = connection.prepareStatement("SELECT * FROM v_ui_uncompared_list WHERE filename ILIKE ? OR groupname ILIKE ? ORDER BY groupname, filename");
	}

	public static int deleteComparison(int file_id, int track_id) throws SQLException {
		if (deleteComparison == null)
			return 0;
		deleteComparison.setInt(1, file_id);
		deleteComparison.setInt(2, track_id);
		deleteMatch.setInt(1, file_id);
		return deleteComparison.executeUpdate() + deleteMatch.executeUpdate();
	}

	public static void disconnect() throws SQLException {
		if (connection != null)
			connection.close();
	}

	public static ResultSet getMatchingDetails(int album_id) throws SQLException {
		if (matchingDetails == null)
			return null;
		matchingDetails.setInt(1, album_id);
		return matchingDetails.executeQuery();
	}

	public static ResultSet getMatchingList(String filter) throws SQLException {
		if (matchingList == null)
			return null;
		if (filter == null)
			filter = "";
		matchingList.setString(1, "%" + filter + "%");
		return matchingList.executeQuery();
	}

	public static ResultSet getSettingList() throws SQLException {
		if (settingList == null)
			return null;
		return settingList.executeQuery();
	}

	public static ResultSet getStatus() throws SQLException {
		if (status == null)
			return null;
		return status.executeQuery();
	}

	public static ResultSet getUncompared(String filter) throws SQLException {
		if (uncompared == null)
			return null;
		if (filter == null)
			filter = "";
		uncompared.setString(1, "%" + filter + "%");
		uncompared.setString(2, "%" + filter + "%");
		return uncompared.executeQuery();
	}

	public static int matchFile(int file_id, int track_id) throws SQLException {
		if (matchFile == null)
			return 0;
		matchFile.setInt(1, track_id);
		matchFile.setInt(2, file_id);
		return matchFile.executeUpdate();
	}

	public static int resetAllSettings() throws SQLException {
		return resetAllSettings.executeUpdate();
	}

	public static int resetSetting(String setting) throws SQLException {
		resetSetting.setString(1, setting);
		return resetSetting.executeUpdate();
	}

	public static int saveMetadata(Metafile file) throws SQLException {
		saveMetadata.setString(1, file.getAlbum());
		saveMetadata.setString(2, file.getAlbumArtist());
		saveMetadata.setString(3, file.getAlbumArtistSortName());
		saveMetadata.setString(4, file.getArtist());
		saveMetadata.setString(5, file.getArtistSortName());
		saveMetadata.setString(6, file.getAlbumArtistMBID());
		saveMetadata.setString(7, file.getAlbumMBID());
		saveMetadata.setString(8, file.getArtistMBID());
		saveMetadata.setString(9, file.getTrackMBID());
		saveMetadata.setString(10, file.getTitle());
		saveMetadata.setInt(11, file.getTracknumber());
		saveMetadata.setString(12, file.getReleased());
		saveMetadata.setString(13, file.getGenre());
		saveMetadata.setBoolean(14, file.isPinned());
		saveMetadata.setInt(15, file.getFileID());
		return saveMetadata.executeUpdate();
	}

	public static int setSetting(String key, String value) throws SQLException {
		setSetting.setString(1, value);
		setSetting.setString(2, key);
		return setSetting.executeUpdate();
	}
}
