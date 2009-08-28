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

	public static void connectPostgreSQL(String url, String username, String password) throws ClassNotFoundException, SQLException {
		Class.forName("org.postgresql.Driver");
		connection = DriverManager.getConnection(url, username, password);

		/* prepared statements */
		matching = connection.prepareStatement("SELECT * FROM v_web_matching_list_albums WHERE album ILIKE ? ORDER BY tracks_compared * avg_score DESC");
	}

	public static void disconnect() throws SQLException {
		connection.close();
	}

	public static ResultSet getMatching() throws SQLException {
		return getMatching("");
	}

	public static ResultSet getMatching(String filter) throws SQLException {
		matching.setString(1, "%" + filter + "%");
		ResultSet rs = matching.executeQuery();
		return rs;
	}
}
