/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.exent.locutus.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author canidae
 */
public class Database {

	private static Connection connection;
	private static PreparedStatement deleteComparison;
	private static PreparedStatement deleteMatch;
	private static PreparedStatement detached;
	private static PreparedStatement matchFile;
	private static PreparedStatement matchingDetails;
	private static PreparedStatement matchingList;
	private static PreparedStatement settingList;

	public static void connectPostgreSQL(String url, String username, String password) throws ClassNotFoundException, SQLException {
		Class.forName("org.postgresql.Driver");
		connection = DriverManager.getConnection(url, username, password);

		/* prepared statements */
		deleteComparison = connection.prepareStatement("DELETE FROM comparison WHERE file_id = ? AND track_id = ?");
		deleteMatch = connection.prepareStatement("UPDATE file SET track_id = NULL WHERE file_id = ?");
		detached = connection.prepareStatement("SELECT * FROM file WHERE track_id IS NULL AND filename LIKE (SELECT value FROM setting WHERE key = 'output_directory') || '%' AND filename ILIKE ? ORDER BY filename");
		matchFile = connection.prepareStatement("UPDATE file SET track_id = ? WHERE file_id = ?");
		matchingDetails = connection.prepareStatement("SELECT * FROM v_ui_matching_details WHERE album_album_id = ? AND (file_track_id IS NULL OR file_track_id = track_track_id) ORDER BY track_tracknumber ASC, comparison_mbid_match DESC, comparison_score DESC");
		matchingList = connection.prepareStatement("SELECT * FROM v_ui_matching_list WHERE album ILIKE ? ORDER BY tracks_compared * avg_score DESC");
		settingList = connection.prepareStatement("SELECT * FROM setting WHERE key ILIKE ?");
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

	public static ResultSet getDetached(String filter) throws SQLException {
		if (detached == null)
			return null;
		if (filter == null)
			filter = "";
		detached.setString(1, "%" + filter + "%");
		return detached.executeQuery();
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

	public static ResultSet getSettingList(String filter) throws SQLException {
		if (settingList == null)
			return null;
		if (filter == null)
			filter = "";
		settingList.setString(1, "%" + filter + "%");
		return settingList.executeQuery();
	}

	public static int matchFile(int file_id, int track_id) throws SQLException {
		if (matchFile == null)
			return 0;
		matchFile.setInt(1, track_id);
		matchFile.setInt(2, file_id);
		return matchFile.executeUpdate();
	}
}
