/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package net.exent.locutus.thread;

import java.sql.ResultSet;
import java.sql.SQLException;
import net.exent.locutus.database.Database;
import net.exent.locutus.gui.Locutus;

/**
 *
 * @author canidae
 */
public class StatusPoller extends Thread {

	private boolean active;

	public StatusPoller() {
		active = true;
	}

	public void checkStatus() {
		try {
			ResultSet rs = Database.getStatus();
			if (rs != null && rs.next()) {
				double progress = rs.getDouble("progress");
				String status = "" + ((double) ((int) (progress * 1000)) / 10.0) + "% - " + (rs.getBoolean("active") ? "" : "not ") + "active";
				Locutus.setProgress(progress, status);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void exit() {
		active = false;
	}

	@Override
	public void run() {
		while (active) {
			checkStatus();
			try {
				Thread.sleep(5000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
}
