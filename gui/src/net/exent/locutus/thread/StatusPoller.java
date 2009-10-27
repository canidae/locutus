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
				String status = (((int) (progress * 1000)) / 10.0) + "% - ";
				if (!rs.getBoolean("active")) {
					status += "inactive";
				} else {
					status += "Estimated time remaining: ";
					double runtime = rs.getDouble("runtime");
					if (progress < 0.001 || runtime <= 0.0) {
						status += "Unknown";
					} else {
						double remaining = runtime / progress - runtime;
						if (remaining > 604800)
							status += (((int) (remaining / 60480.0)) / 10.0) + " weeks";
						else if (remaining > 86400)
							status += (((int) (remaining / 8640.0)) / 10.0) + " days";
						else if (remaining > 3600)
							status += (((int) (remaining / 360.0)) / 10.0) + " hours";
						else if (remaining > 60)
							status += (((int) (remaining / 6.0)) / 10.0) + " minutes";
						else
							status += (((int) (remaining * 10.0)) / 10.0) + " seconds";
					}
				}
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
