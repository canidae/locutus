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

	public static void connectPostgreSQL(String url, String username, String password) throws ClassNotFoundException, SQLException {
		Class.forName("org.postgresql.Driver");
		connection = DriverManager.getConnection(url, username, password);

		/* prepared statements */
		matching = connection.prepareStatement("SELECT * FROM v_web_matching_list_albums WHERE album ILIKE ? ORDER BY tracks_compared * avg_score DESC");
		detached = connection.prepareStatement("SELECT * FROM file WHERE track_id IS NULL AND filename LIKE (SELECT value FROM setting WHERE key = 'output_directory') || '%' AND filename ILIKE ? ORDER BY filename");
		artists = connection.prepareStatement("SELECT * FROM artist WHERE name ILIKE ? ORDER BY sortname");
	}

	public static void disconnect() throws SQLException {
		if (connection != null)
			connection.close();
	}

	public static ResultSet getMatching(String filter) throws SQLException {
		if (matching == null)
			return null;
		matching.setString(1, "%" + filter + "%");
		System.out.println(matching);
		return matching.executeQuery();
	}

	public static ResultSet getDetached(String filter) throws SQLException {
		if (detached == null)
			return null;
		detached.setString(1, "%" + filter + "%");
		System.out.println(detached);
		return detached.executeQuery();
	}

	public static ResultSet getArtists(String filter) throws SQLException {
		if (artists == null)
			return null;
		artists.setString(1, "%" + filter + "%");
		System.out.println(artists);
		return artists.executeQuery();
	}
}
