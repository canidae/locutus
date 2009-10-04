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
	private static PreparedStatement matching;
	private static PreparedStatement detached;
	private static PreparedStatement artists;
	private static PreparedStatement album;
	private static PreparedStatement delete_comparison;
	private static PreparedStatement delete_match;
	private static PreparedStatement match_file;

	public static void connectPostgreSQL(String url, String username, String password) throws ClassNotFoundException, SQLException {
		Class.forName("org.postgresql.Driver");
		connection = DriverManager.getConnection(url, username, password);

		/* prepared statements */
		matching = connection.prepareStatement("SELECT * FROM v_web_matching_list_albums WHERE album ILIKE ? ORDER BY tracks_compared * avg_score DESC");
		detached = connection.prepareStatement("SELECT * FROM file WHERE track_id IS NULL AND filename LIKE (SELECT value FROM setting WHERE key = 'output_directory') || '%' AND filename ILIKE ? ORDER BY filename");
		artists = connection.prepareStatement("SELECT * FROM artist WHERE name ILIKE ? ORDER BY sortname");
		album = connection.prepareStatement("SELECT * FROM v_web_album_list_tracks_and_matching_files WHERE album_id = ? AND (file_track_id IS NULL OR file_track_id = track_id) ORDER BY tracknumber ASC, mbid_match DESC, score DESC");
		delete_comparison = connection.prepareStatement("DELETE FROM comparison WHERE file_id = ? AND track_id = ?");
		delete_match = connection.prepareStatement("UPDATE file SET track_id = NULL WHERE file_id = ?");
		match_file = connection.prepareStatement("UPDATE file SET track_id = ? WHERE file_id = ?");
	}

	public static void disconnect() throws SQLException {
		if (connection != null)
			connection.close();
	}

	public static ResultSet getMatching(String filter) throws SQLException {
		if (matching == null)
			return null;
		if (filter == null)
			filter = "";
		matching.setString(1, "%" + filter + "%");
		return matching.executeQuery();
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

	public static ResultSet getAlbum(int album_id) throws SQLException {
		if (album == null)
			return null;
		album.setInt(1, album_id);
		return album.executeQuery();
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
