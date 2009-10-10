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
	private static PreparedStatement matching_list;
	private static PreparedStatement detached;
	private static PreparedStatement artists;
	private static PreparedStatement matching_details;
	private static PreparedStatement delete_comparison;
	private static PreparedStatement delete_match;
	private static PreparedStatement match_file;

	public static void connectPostgreSQL(String url, String username, String password) throws ClassNotFoundException, SQLException {
		Class.forName("org.postgresql.Driver");
		connection = DriverManager.getConnection(url, username, password);

		/* prepared statements */
		detached = connection.prepareStatement("SELECT * FROM file WHERE track_id IS NULL AND filename LIKE (SELECT value FROM setting WHERE key = 'output_directory') || '%' AND filename ILIKE ? ORDER BY filename");
		artists = connection.prepareStatement("SELECT * FROM artist WHERE name ILIKE ? ORDER BY sortname");
		delete_comparison = connection.prepareStatement("DELETE FROM comparison WHERE file_id = ? AND track_id = ?");
		delete_match = connection.prepareStatement("UPDATE file SET track_id = NULL WHERE file_id = ?");
		match_file = connection.prepareStatement("UPDATE file SET track_id = ? WHERE file_id = ?");
		matching_list = connection.prepareStatement("SELECT * FROM v_ui_matching_list WHERE album ILIKE ? ORDER BY tracks_compared * avg_score DESC");
		matching_details = connection.prepareStatement("SELECT * FROM v_ui_matching_details WHERE album_album_id = ? AND (file_track_id IS NULL OR file_track_id = track_track_id) ORDER BY track_tracknumber ASC, comparison_mbid_match DESC, comparison_score DESC");
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

	public static ResultSet getArtists(String filter) throws SQLException {
		if (artists == null)
			return null;
		if (filter == null)
			filter = "";
		artists.setString(1, "%" + filter + "%");
		return artists.executeQuery();
	}

	public static ResultSet getMatchingList(String filter) throws SQLException {
		if (matching_list == null)
			return null;
		if (filter == null)
			filter = "";
		matching_list.setString(1, "%" + filter + "%");
		return matching_list.executeQuery();
	}

	public static ResultSet getMatchingDetails(int album_id) throws SQLException {
		if (matching_details == null)
			return null;
		matching_details.setInt(1, album_id);
		return matching_details.executeQuery();
	}

	public static int deleteComparison(int file_id, int track_id) throws SQLException {
		if (delete_comparison == null)
			return 0;
		delete_comparison.setInt(1, file_id);
		delete_comparison.setInt(2, track_id);
		delete_match.setInt(1, file_id);
		return delete_comparison.executeUpdate() + delete_match.executeUpdate();
	}

	public static int matchFile(int file_id, int track_id) throws SQLException {
		if (match_file == null)
			return 0;
		match_file.setInt(1, track_id);
		match_file.setInt(2, file_id);
		return match_file.executeUpdate();
	}
}
