/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * Locutus.java
 *
 * Created on Aug 27, 2009, 10:35:02 PM
 */
package net.exent.locutus.gui;

import java.sql.SQLException;
import javax.swing.JOptionPane;
import net.exent.locutus.database.Database;

/**
 *
 * @author canidae
 */
public class Locutus extends javax.swing.JFrame {

	/** Creates new form Locutus */
	public Locutus() {
		initComponents();
	}

	/** This method is called from within the constructor to
	 * initialize the form.
	 * WARNING: Do NOT modify this code. The content of this method is
	 * always regenerated by the Form Editor.
	 */
	@SuppressWarnings("unchecked")
        // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
        private void initComponents() {

                connectFrame = new javax.swing.JFrame();
                driverLabel = new javax.swing.JLabel();
                driverCombo = new javax.swing.JComboBox();
                hostLabel = new javax.swing.JLabel();
                hostTextField = new javax.swing.JTextField();
                usernameLabel = new javax.swing.JLabel();
                usernameTextField = new javax.swing.JTextField();
                passwordLabel = new javax.swing.JLabel();
                connectButton = new javax.swing.JButton();
                cancelButton = new javax.swing.JButton();
                databaseLabel = new javax.swing.JLabel();
                databaseTextField = new javax.swing.JTextField();
                passwordPasswordField = new javax.swing.JPasswordField();
                jTabbedPane1 = new javax.swing.JTabbedPane();
                matching = new net.exent.locutus.gui.Matching();
                menuBar = new javax.swing.JMenuBar();
                fileMenu = new javax.swing.JMenu();
                fileConnect = new javax.swing.JMenuItem();
                fileSeparator1 = new javax.swing.JSeparator();
                fileExit = new javax.swing.JMenuItem();

                connectFrame.setTitle("Connect to database");
                connectFrame.setMinimumSize(new java.awt.Dimension(289, 229));
                connectFrame.setResizable(false);

                driverLabel.setText("Driver");

                driverCombo.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "jdbc:postgresql://" }));

                hostLabel.setText("Host");

                hostTextField.setText("example.com");
                hostTextField.addFocusListener(new java.awt.event.FocusAdapter() {
                        public void focusGained(java.awt.event.FocusEvent evt) {
                                hostTextFieldFocusGained(evt);
                        }
                        public void focusLost(java.awt.event.FocusEvent evt) {
                                hostTextFieldFocusLost(evt);
                        }
                });

                usernameLabel.setText("Username");

                usernameTextField.setText("locutus");
                usernameTextField.addFocusListener(new java.awt.event.FocusAdapter() {
                        public void focusGained(java.awt.event.FocusEvent evt) {
                                usernameTextFieldFocusGained(evt);
                        }
                        public void focusLost(java.awt.event.FocusEvent evt) {
                                usernameTextFieldFocusLost(evt);
                        }
                });

                passwordLabel.setText("Password");

                connectButton.setText("Connect");
                connectButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                connectButtonActionPerformed(evt);
                        }
                });

                cancelButton.setText("Cancel");
                cancelButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                cancelButtonActionPerformed(evt);
                        }
                });

                databaseLabel.setText("Database");

                databaseTextField.setText("locutus");
                databaseTextField.addFocusListener(new java.awt.event.FocusAdapter() {
                        public void focusGained(java.awt.event.FocusEvent evt) {
                                databaseTextFieldFocusGained(evt);
                        }
                        public void focusLost(java.awt.event.FocusEvent evt) {
                                databaseTextFieldFocusLost(evt);
                        }
                });

                passwordPasswordField.addFocusListener(new java.awt.event.FocusAdapter() {
                        public void focusGained(java.awt.event.FocusEvent evt) {
                                passwordPasswordFieldFocusGained(evt);
                        }
                        public void focusLost(java.awt.event.FocusEvent evt) {
                                passwordPasswordFieldFocusLost(evt);
                        }
                });

                javax.swing.GroupLayout connectFrameLayout = new javax.swing.GroupLayout(connectFrame.getContentPane());
                connectFrame.getContentPane().setLayout(connectFrameLayout);
                connectFrameLayout.setHorizontalGroup(
                        connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(connectFrameLayout.createSequentialGroup()
                                .addContainerGap()
                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                        .addGroup(connectFrameLayout.createSequentialGroup()
                                                .addComponent(connectButton, javax.swing.GroupLayout.PREFERRED_SIZE, 115, javax.swing.GroupLayout.PREFERRED_SIZE)
                                                .addGap(35, 35, 35)
                                                .addComponent(cancelButton, javax.swing.GroupLayout.DEFAULT_SIZE, 115, Short.MAX_VALUE))
                                        .addGroup(connectFrameLayout.createSequentialGroup()
                                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                                        .addComponent(passwordLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(usernameLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(databaseLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(hostLabel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(driverLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 76, Short.MAX_VALUE))
                                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 12, Short.MAX_VALUE)
                                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                                                        .addComponent(driverCombo, javax.swing.GroupLayout.Alignment.LEADING, 0, 177, Short.MAX_VALUE)
                                                        .addComponent(hostTextField, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 177, Short.MAX_VALUE)
                                                        .addComponent(databaseTextField, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 177, Short.MAX_VALUE)
                                                        .addComponent(usernameTextField, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 177, Short.MAX_VALUE)
                                                        .addComponent(passwordPasswordField, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, 177, Short.MAX_VALUE))))
                                .addContainerGap())
                );
                connectFrameLayout.setVerticalGroup(
                        connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addGroup(connectFrameLayout.createSequentialGroup()
                                .addContainerGap()
                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(driverLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 17, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(driverCombo, javax.swing.GroupLayout.PREFERRED_SIZE, 23, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(hostLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 17, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(hostTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(databaseLabel)
                                        .addComponent(databaseTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(usernameLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 17, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(usernameTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(passwordLabel)
                                        .addComponent(passwordPasswordField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 16, Short.MAX_VALUE)
                                .addGroup(connectFrameLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                        .addComponent(connectButton, javax.swing.GroupLayout.PREFERRED_SIZE, 42, javax.swing.GroupLayout.PREFERRED_SIZE)
                                        .addComponent(cancelButton, javax.swing.GroupLayout.PREFERRED_SIZE, 42, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addContainerGap())
                );

                setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
                setTitle("Locutus");

                jTabbedPane1.addTab("Matching", matching);

                fileMenu.setText("File");

                fileConnect.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_O, java.awt.event.InputEvent.CTRL_MASK));
                fileConnect.setMnemonic('C');
                fileConnect.setText("Connect...");
                fileConnect.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                fileConnectActionPerformed(evt);
                        }
                });
                fileMenu.add(fileConnect);
                fileMenu.add(fileSeparator1);

                fileExit.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_Q, java.awt.event.InputEvent.CTRL_MASK));
                fileExit.setMnemonic('x');
                fileExit.setText("Exit");
                fileExit.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                fileExitActionPerformed(evt);
                        }
                });
                fileMenu.add(fileExit);

                menuBar.add(fileMenu);

                setJMenuBar(menuBar);

                javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
                getContentPane().setLayout(layout);
                layout.setHorizontalGroup(
                        layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(jTabbedPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 672, Short.MAX_VALUE)
                );
                layout.setVerticalGroup(
                        layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(jTabbedPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 423, Short.MAX_VALUE)
                );

                pack();
        }// </editor-fold>//GEN-END:initComponents

	private void connectButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_connectButtonActionPerformed
		try {
			connectFrame.setVisible(false);
			Database.disconnect();
			String db = driverCombo.getSelectedItem().toString();
			db += hostTextField.getText();
			db += "/";
			db += databaseTextField.getText();
			Database.connectPostgreSQL(db, usernameTextField.getText(), new String(passwordPasswordField.getPassword()));
			jTabbedPane1.setSelectedComponent(matching);
			matching.updateTable();
		} catch (ClassNotFoundException e) {
			JOptionPane.showMessageDialog(this, e);
			e.printStackTrace();
		} catch (SQLException e) {
			JOptionPane.showMessageDialog(this, e);
			e.printStackTrace();
		}
	}//GEN-LAST:event_connectButtonActionPerformed

	private void fileConnectActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_fileConnectActionPerformed
		connectFrame.setVisible(true);
	}//GEN-LAST:event_fileConnectActionPerformed

	private void cancelButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_cancelButtonActionPerformed
		connectFrame.setVisible(false);
	}//GEN-LAST:event_cancelButtonActionPerformed

	private void hostTextFieldFocusGained(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_hostTextFieldFocusGained
		hostTextField.selectAll();
	}//GEN-LAST:event_hostTextFieldFocusGained

	private void hostTextFieldFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_hostTextFieldFocusLost
		hostTextField.select(0, 0);
	}//GEN-LAST:event_hostTextFieldFocusLost

	private void databaseTextFieldFocusGained(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_databaseTextFieldFocusGained
		databaseTextField.selectAll();
	}//GEN-LAST:event_databaseTextFieldFocusGained

	private void databaseTextFieldFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_databaseTextFieldFocusLost
		databaseTextField.select(0, 0);
	}//GEN-LAST:event_databaseTextFieldFocusLost

	private void usernameTextFieldFocusGained(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_usernameTextFieldFocusGained
		usernameTextField.selectAll();
	}//GEN-LAST:event_usernameTextFieldFocusGained

	private void usernameTextFieldFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_usernameTextFieldFocusLost
		usernameTextField.select(0, 0);
	}//GEN-LAST:event_usernameTextFieldFocusLost

	private void passwordPasswordFieldFocusGained(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_passwordPasswordFieldFocusGained
		passwordPasswordField.selectAll();
	}//GEN-LAST:event_passwordPasswordFieldFocusGained

	private void passwordPasswordFieldFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_passwordPasswordFieldFocusLost
		passwordPasswordField.select(0, 0);
	}//GEN-LAST:event_passwordPasswordFieldFocusLost

	private void fileExitActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_fileExitActionPerformed
		try {
			Database.disconnect();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		this.dispose();
	}//GEN-LAST:event_fileExitActionPerformed

	/**
	 * @param args the command line arguments
	 */
	public static void main(String args[]) {
		java.awt.EventQueue.invokeLater(new Runnable() {

			public void run() {
				new Locutus().setVisible(true);
			}
		});
	}
        // Variables declaration - do not modify//GEN-BEGIN:variables
        private javax.swing.JButton cancelButton;
        private javax.swing.JButton connectButton;
        private javax.swing.JFrame connectFrame;
        private javax.swing.JLabel databaseLabel;
        private javax.swing.JTextField databaseTextField;
        private javax.swing.JComboBox driverCombo;
        private javax.swing.JLabel driverLabel;
        private javax.swing.JMenuItem fileConnect;
        private javax.swing.JMenuItem fileExit;
        private javax.swing.JMenu fileMenu;
        private javax.swing.JSeparator fileSeparator1;
        private javax.swing.JLabel hostLabel;
        private javax.swing.JTextField hostTextField;
        private javax.swing.JTabbedPane jTabbedPane1;
        private net.exent.locutus.gui.Matching matching;
        private javax.swing.JMenuBar menuBar;
        private javax.swing.JLabel passwordLabel;
        private javax.swing.JPasswordField passwordPasswordField;
        private javax.swing.JLabel usernameLabel;
        private javax.swing.JTextField usernameTextField;
        // End of variables declaration//GEN-END:variables
}