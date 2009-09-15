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
	private static PreparedStatement albums;

	public static void connectPostgreSQL(String url, String username, String password) throws ClassNotFoundException, SQLException {
		Class.forName("org.postgresql.Driver");
		connection = DriverManager.getConnection(url, username, password);

		/* prepared statements */
		matching = connection.prepareStatement("SELECT * FROM v_web_matching_list_albums WHERE album ILIKE ? ORDER BY tracks_compared * avg_score DESC");
		detached = connection.prepareStatement("SELECT * FROM file WHERE track_id IS NULL AND filename LIKE (SELECT value FROM setting WHERE key = 'output_directory') || '%' AND filename ILIKE ? ORDER BY filename");
		artists = connection.prepareStatement("SELECT * FROM artist WHERE name ILIKE ? ORDER BY sortname");
		albums = connection.prepareStatement("SELECT * FROM album WHERE title ILIKE ? ORDER BY title");
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

	public static ResultSet getAlbums(String filter) throws SQLException {
		if (albums == null)
			return null;
		if (filter == null)
			filter = "";
		albums.setString(1, "%" + filter + "%");
		return albums.executeQuery();
	}
}
