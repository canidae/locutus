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

import java.awt.Component;
import java.awt.event.KeyEvent;
import java.sql.SQLException;
import javax.swing.JOptionPane;
import javax.swing.ToolTipManager;
import net.exent.locutus.data.Metafile;
import net.exent.locutus.database.Database;

/**
 *
 * @author canidae
 */
public class Locutus extends javax.swing.JFrame {

	/** Creates new form Locutus */
	public Locutus() {
		initComponents();
		/* make tooltips stay a bit longer */
		ToolTipManager.sharedInstance().setDismissDelay(90000);
	}

	public static String getFilter() {
		return filterTextField.getText();
	}

	public static void setMetadata(Metafile[] files) {
		if (files.length <= 0)
			return;

		clearMetadata();
		if (files.length > 1) {
			fileFilenameLabel.setText("File: <" + files.length + " files>");
			fileDuplicate.setSelected(false);
			fileModified.setSelected(false);
			filePinned.setSelected(false);
		} else {
			fileFilenameLabel.setText("File: " + files[0].getFilename());
			fileDuplicate.setSelected(files[0].isDuplicate());
			fileModified.setSelected(files[0].isModified());
			filePinned.setSelected(files[0].isPinned());
		}

		boolean first = true;
		for (Metafile file : files) {
			if (first || fileAlbumArtistMBIDValue.getText().equals(file.getAlbumArtistMBID()))
				fileAlbumArtistMBIDValue.setText(file.getAlbumArtistMBID());
			if (first || fileAlbumArtistSortValue.getText().equals(file.getAlbumArtistSortName()))
				fileAlbumArtistSortValue.setText(file.getAlbumArtistSortName());
			if (first || fileAlbumArtistValue.getText().equals(file.getAlbumArtist()))
				fileAlbumArtistValue.setText(file.getAlbumArtist());
			if (first || fileAlbumMBIDValue.getText().equals(file.getAlbumMBID()))
				fileAlbumMBIDValue.setText(file.getAlbumMBID());
			if (first || fileAlbumValue.getText().equals(file.getAlbum()))
				fileAlbumValue.setText(file.getAlbum());
			if (first || fileArtistMBIDValue.getText().equals(file.getArtistMBID()))
				fileArtistMBIDValue.setText(file.getArtistMBID());
			if (first || fileArtistSortValue.getText().equals(file.getArtistSortName()))
				fileArtistSortValue.setText(file.getArtistSortName());
			if (first || fileArtistValue.getText().equals(file.getArtist()))
				fileArtistValue.setText(file.getArtist());
			if (first || fileBitrateValue.getText().equals("" + file.getBitrate()))
				fileBitrateValue.setText("" + file.getBitrate());
			if (first || fileChannelsValue.getText().equals("" + file.getChannels()))
				fileChannelsValue.setText("" + file.getChannels());
			if (first || fileDurationValue.getText().equals("" + file.getDuration()))
				fileDurationValue.setText("" + file.getDuration());
			if (first || fileFileIDValue.getText().equals("" + file.getFileID()))
				fileFileIDValue.setText("" + file.getFileID());
			if (first || fileGenreValue.getText().equals(file.getGenre()))
				fileGenreValue.setText(file.getGenre());
			if (first || fileGroupValue.getText().equals(file.getGroup()))
				fileGroupValue.setText(file.getGroup());
			if (first || fileReleasedValue.getText().equals(file.getReleased()))
				fileReleasedValue.setText(file.getReleased());
			if (first || fileSamplerateValue.getText().equals("" + file.getSamplerate()))
				fileSamplerateValue.setText("" + file.getSamplerate());
			if (first || fileTitleValue.getText().equals(file.getTitle()))
				fileTitleValue.setText(file.getTitle());
			if (first || fileTrackIDValue.getText().equals("" + file.getTrackID()))
				fileTrackIDValue.setText("" + file.getTrackID());
			if (first || fileTrackMBIDValue.getText().equals(file.getTrackMBID()))
				fileTrackMBIDValue.setText(file.getTrackMBID());
			if (first || fileTracknumberValue.getText().equals("" + file.getTracknumber()))
				fileTracknumberValue.setText("" + file.getTracknumber());
			first = false;
		}
	}

	public static void clearMetadata() {
		fileAlbumArtistMBIDValue.setText("");
		fileAlbumArtistSortValue.setText("");
		fileAlbumArtistValue.setText("");
		fileAlbumMBIDValue.setText("");
		fileAlbumValue.setText("");
		fileArtistMBIDValue.setText("");
		fileArtistSortValue.setText("");
		fileArtistValue.setText("");
		fileBitrateValue.setText("");
		fileChannelsValue.setText("");
		fileDuplicate.setSelected(false);
		fileDurationValue.setText("");
		fileFileIDValue.setText("");
		fileFilenameLabel.setText("File: <none>");
		fileGenreValue.setText("");
		fileGroupValue.setText("");
		fileModified.setSelected(false);
		filePinned.setSelected(false);
		fileReleasedValue.setText("");
		fileSamplerateValue.setText("");
		fileTitleValue.setText("");
		fileTrackIDValue.setText("");
		fileTrackMBIDValue.setText("");
		fileTracknumberValue.setText("");
	}

	public static void showMetadata() {
		Locutus.metadataPanel.setVisible(true);
	}

	public static void hideMetadata() {
		Locutus.metadataPanel.setVisible(false);
	}

	/** This method is called from within the constructor to
	 * initialize the form.
	 * WARNING: Do NOT modify this code. The content of this method is
	 * always regenerated by the Form Editor.
	 */
	@SuppressWarnings("unchecked")
        // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
        private void initComponents() {
                java.awt.GridBagConstraints gridBagConstraints;

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
                tabPane = new javax.swing.JTabbedPane();
                matching = new net.exent.locutus.gui.Matching();
                detached = new net.exent.locutus.gui.Detached();
                settings = new net.exent.locutus.gui.Settings();
                metadataPanel = new javax.swing.JPanel();
                fileFilenameLabel = new javax.swing.JLabel();
                miscPanel = new javax.swing.JPanel();
                fileTrackIDLabel = new javax.swing.JLabel();
                fileTrackIDValue = new javax.swing.JTextField();
                fileGroupLabel = new javax.swing.JLabel();
                filePinned = new javax.swing.JCheckBox();
                fileFileIDValue = new javax.swing.JTextField();
                fileFileIDLabel = new javax.swing.JLabel();
                fileGroupValue = new javax.swing.JTextField();
                fileModified = new javax.swing.JCheckBox();
                fileDuplicate = new javax.swing.JCheckBox();
                fileDurationLabel = new javax.swing.JLabel();
                fileDurationValue = new javax.swing.JLabel();
                fileChannelsLabel = new javax.swing.JLabel();
                fileChannelsValue = new javax.swing.JLabel();
                fileBitrateLabel = new javax.swing.JLabel();
                fileBitrateValue = new javax.swing.JLabel();
                fileSamplerateLabel = new javax.swing.JLabel();
                fileSamplerateValue = new javax.swing.JLabel();
                fileSaveButton = new javax.swing.JButton();
                artistPanel = new javax.swing.JPanel();
                fileArtistLabel = new javax.swing.JLabel();
                fileArtistValue = new javax.swing.JTextField();
                fileArtistSortLabel = new javax.swing.JLabel();
                fileArtistSortValue = new javax.swing.JTextField();
                fileArtistMBIDLabel = new javax.swing.JLabel();
                fileArtistMBIDValue = new javax.swing.JTextField();
                trackPanel = new javax.swing.JPanel();
                fileTrackMBIDValue = new javax.swing.JTextField();
                fileGenreValue = new javax.swing.JTextField();
                fileGenreLabel = new javax.swing.JLabel();
                fileTrackMBIDLabel = new javax.swing.JLabel();
                fileTitleValue = new javax.swing.JTextField();
                fileTitleLabel = new javax.swing.JLabel();
                fileTracknumberValue = new javax.swing.JTextField();
                fileTracknumberLabel = new javax.swing.JLabel();
                albumPanel = new javax.swing.JPanel();
                fileAlbumValue = new javax.swing.JTextField();
                fileAlbumLabel = new javax.swing.JLabel();
                fileReleasedValue = new javax.swing.JTextField();
                fileReleasedLabel = new javax.swing.JLabel();
                fileAlbumMBIDValue = new javax.swing.JTextField();
                fileAlbumMBIDLabel = new javax.swing.JLabel();
                albumArtistPanel = new javax.swing.JPanel();
                fileAlbumArtistLabel = new javax.swing.JLabel();
                fileAlbumArtistValue = new javax.swing.JTextField();
                fileAlbumArtistMBIDLabel = new javax.swing.JLabel();
                fileAlbumArtistMBIDValue = new javax.swing.JTextField();
                fileAlbumArtistSortLabel = new javax.swing.JLabel();
                fileAlbumArtistSortValue = new javax.swing.JTextField();
                topPanel = new javax.swing.JPanel();
                filterLabel = new javax.swing.JLabel();
                filterTextField = new javax.swing.JTextField();
                updateButton = new javax.swing.JButton();
                openButton = new javax.swing.JButton();
                quitButton = new javax.swing.JButton();
                locutusProgressLabel = new javax.swing.JLabel();
                locutusProgressBar = new javax.swing.JProgressBar();

                connectFrame.setTitle("Connect to database");
                connectFrame.setMinimumSize(new java.awt.Dimension(289, 229));
                connectFrame.setResizable(false);

                driverLabel.setText("Driver");

                driverCombo.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "jdbc:postgresql://" }));

                hostLabel.setText("Host");

                hostTextField.setText("localhost");
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

                tabPane.addTab("Matching", matching);
                tabPane.addTab("Detached", detached);
                tabPane.addTab("Settings", settings);

                getContentPane().add(tabPane, java.awt.BorderLayout.CENTER);

                metadataPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Metadata"));
                metadataPanel.setLayout(new java.awt.GridBagLayout());

                fileFilenameLabel.setText("File: <none>");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                metadataPanel.add(fileFilenameLabel, gridBagConstraints);

                miscPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Misc"));
                miscPanel.setMaximumSize(new java.awt.Dimension(298, 204));
                miscPanel.setLayout(new java.awt.GridBagLayout());

                fileTrackIDLabel.setText("Track ID:");
                fileTrackIDLabel.setMaximumSize(new java.awt.Dimension(79, 17));
                fileTrackIDLabel.setMinimumSize(new java.awt.Dimension(79, 17));
                fileTrackIDLabel.setPreferredSize(new java.awt.Dimension(79, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileTrackIDLabel, gridBagConstraints);

                fileTrackIDValue.setToolTipText("<html>The ID of the track this or these files are matched with.<br />\nIf this field is set and you save any changes to the metadata (with the exception of genre) then this field will be cleared as that most likely means the file[s] were mismatched.<br />\nWhile you can, you should not set this field manually unless you know what you're doing.</html>");
                fileTrackIDValue.setMaximumSize(new java.awt.Dimension(64, 25));
                fileTrackIDValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileTrackIDValue.setPreferredSize(new java.awt.Dimension(64, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileTrackIDValue, gridBagConstraints);

                fileGroupLabel.setText("Group:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.gridwidth = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileGroupLabel, gridBagConstraints);

                filePinned.setText("Pinned");
                filePinned.setToolTipText("<html>A pinned file will have preference above other duplicates regardless of quality.<br />\nFor example, you got an album with MP3-files and then 1 extra file from the same album, but in FLAC format.<br />\nMost likely the FLAC will appear in the output directory while the duplicate MP3 will be placed in the duplicate directory.<br />\nIf you pin the duplicate MP3 then the FLAC will be placed in the duplicate directory and the MP3 in the output directory.<br />\nIf you pin multiple duplicates the behaviour is undefined, it's usually better to delete the duplicate you don't want.</html>");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 6;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(filePinned, gridBagConstraints);

                fileFileIDValue.setEditable(false);
                fileFileIDValue.setFocusable(false);
                fileFileIDValue.setMaximumSize(new java.awt.Dimension(64, 25));
                fileFileIDValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileFileIDValue.setPreferredSize(new java.awt.Dimension(64, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileFileIDValue, gridBagConstraints);

                fileFileIDLabel.setText("File ID:");
                fileFileIDLabel.setMaximumSize(new java.awt.Dimension(63, 17));
                fileFileIDLabel.setMinimumSize(new java.awt.Dimension(63, 17));
                fileFileIDLabel.setPreferredSize(new java.awt.Dimension(63, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileFileIDLabel, gridBagConstraints);

                fileGroupValue.setEditable(false);
                fileGroupValue.setToolTipText("<html>The group the file[s] belong to.<br />\nThe value for this field is automatically generated by the daemon using audio format, samplerate, channels and album title or path if album title is not set.<br />\nIf you wish to group files together manually you should write in the same album title for all of them (you still won't be able to do anything about format, samplerate or channels, though).</html>");
                fileGroupValue.setFocusable(false);
                fileGroupValue.setMaximumSize(new java.awt.Dimension(256, 25));
                fileGroupValue.setMinimumSize(new java.awt.Dimension(256, 25));
                fileGroupValue.setPreferredSize(new java.awt.Dimension(256, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.gridwidth = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileGroupValue, gridBagConstraints);

                fileModified.setText("Modified");
                fileModified.setToolTipText("Whether the file[s] are modified by the user since the last time the daemon processed the file[s].");
                fileModified.setEnabled(false);
                fileModified.setFocusable(false);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 5;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileModified, gridBagConstraints);

                fileDuplicate.setText("Duplicate");
                fileDuplicate.setToolTipText("Whether the file[s] are duplicates.");
                fileDuplicate.setEnabled(false);
                fileDuplicate.setFocusable(false);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 5;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileDuplicate, gridBagConstraints);

                fileDurationLabel.setText("Duration:");
                fileDurationLabel.setMaximumSize(new java.awt.Dimension(63, 17));
                fileDurationLabel.setMinimumSize(new java.awt.Dimension(63, 17));
                fileDurationLabel.setPreferredSize(new java.awt.Dimension(63, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileDurationLabel, gridBagConstraints);

                fileDurationValue.setMinimumSize(new java.awt.Dimension(64, 17));
                fileDurationValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileDurationValue, gridBagConstraints);

                fileChannelsLabel.setText("Channels:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileChannelsLabel, gridBagConstraints);

                fileChannelsValue.setMinimumSize(new java.awt.Dimension(64, 17));
                fileChannelsValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileChannelsValue, gridBagConstraints);

                fileBitrateLabel.setText("Bitrate:");
                fileBitrateLabel.setMaximumSize(new java.awt.Dimension(79, 17));
                fileBitrateLabel.setMinimumSize(new java.awt.Dimension(79, 17));
                fileBitrateLabel.setPreferredSize(new java.awt.Dimension(79, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileBitrateLabel, gridBagConstraints);

                fileBitrateValue.setMinimumSize(new java.awt.Dimension(64, 17));
                fileBitrateValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileBitrateValue, gridBagConstraints);

                fileSamplerateLabel.setText("Samplerate:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileSamplerateLabel, gridBagConstraints);

                fileSamplerateValue.setMinimumSize(new java.awt.Dimension(64, 17));
                fileSamplerateValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileSamplerateValue, gridBagConstraints);

                fileSaveButton.setMnemonic('S');
                fileSaveButton.setText("Save metadata");
                fileSaveButton.setFocusable(false);
                fileSaveButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                fileSaveButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 6;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                miscPanel.add(fileSaveButton, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.gridheight = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.SOUTHWEST;
                metadataPanel.add(miscPanel, gridBagConstraints);

                artistPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Artist"));
                artistPanel.setLayout(new java.awt.GridBagLayout());

                fileArtistLabel.setText("Name:");
                fileArtistLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileArtistLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileArtistLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistLabel, gridBagConstraints);

                fileArtistValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistValue, gridBagConstraints);

                fileArtistSortLabel.setText("Sort name:");
                fileArtistSortLabel.setOpaque(true);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistSortLabel, gridBagConstraints);

                fileArtistSortValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistSortValue, gridBagConstraints);

                fileArtistMBIDLabel.setText("MBID:");
                fileArtistMBIDLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileArtistMBIDLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileArtistMBIDLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistMBIDLabel, gridBagConstraints);

                fileArtistMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistMBIDValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.weightx = 1.0;
                metadataPanel.add(artistPanel, gridBagConstraints);

                trackPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Track"));
                trackPanel.setLayout(new java.awt.GridBagLayout());

                fileTrackMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTrackMBIDValue, gridBagConstraints);

                fileGenreValue.setPreferredSize(new java.awt.Dimension(64, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileGenreValue, gridBagConstraints);

                fileGenreLabel.setText("Genre:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileGenreLabel, gridBagConstraints);

                fileTrackMBIDLabel.setText("MBID:");
                fileTrackMBIDLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileTrackMBIDLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileTrackMBIDLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTrackMBIDLabel, gridBagConstraints);

                fileTitleValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTitleValue, gridBagConstraints);

                fileTitleLabel.setText("Title:");
                fileTitleLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileTitleLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileTitleLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTitleLabel, gridBagConstraints);

                fileTracknumberValue.setMaximumSize(new java.awt.Dimension(32, 25));
                fileTracknumberValue.setMinimumSize(new java.awt.Dimension(32, 25));
                fileTracknumberValue.setPreferredSize(new java.awt.Dimension(32, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTracknumberValue, gridBagConstraints);

                fileTracknumberLabel.setText("Tracknum:");
                fileTracknumberLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileTracknumberLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileTracknumberLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTracknumberLabel, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.SOUTH;
                gridBagConstraints.weightx = 1.0;
                metadataPanel.add(trackPanel, gridBagConstraints);

                albumPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Album"));
                albumPanel.setPreferredSize(new java.awt.Dimension(304, 104));
                albumPanel.setLayout(new java.awt.GridBagLayout());

                fileAlbumValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(fileAlbumValue, gridBagConstraints);

                fileAlbumLabel.setText("Title:");
                fileAlbumLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileAlbumLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileAlbumLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(fileAlbumLabel, gridBagConstraints);

                fileReleasedValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(fileReleasedValue, gridBagConstraints);

                fileReleasedLabel.setText("Released:");
                fileReleasedLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileReleasedLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileReleasedLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(fileReleasedLabel, gridBagConstraints);

                fileAlbumMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(fileAlbumMBIDValue, gridBagConstraints);

                fileAlbumMBIDLabel.setText("MBID:");
                fileAlbumMBIDLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileAlbumMBIDLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileAlbumMBIDLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(fileAlbumMBIDLabel, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.weightx = 2.0;
                metadataPanel.add(albumPanel, gridBagConstraints);

                albumArtistPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Album artist"));
                albumArtistPanel.setLayout(new java.awt.GridBagLayout());

                fileAlbumArtistLabel.setText("Name:");
                fileAlbumArtistLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileAlbumArtistLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileAlbumArtistLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(fileAlbumArtistLabel, gridBagConstraints);

                fileAlbumArtistValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(fileAlbumArtistValue, gridBagConstraints);

                fileAlbumArtistMBIDLabel.setText("MBID:");
                fileAlbumArtistMBIDLabel.setMaximumSize(new java.awt.Dimension(72, 17));
                fileAlbumArtistMBIDLabel.setMinimumSize(new java.awt.Dimension(72, 17));
                fileAlbumArtistMBIDLabel.setPreferredSize(new java.awt.Dimension(72, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(fileAlbumArtistMBIDLabel, gridBagConstraints);

                fileAlbumArtistMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(fileAlbumArtistMBIDValue, gridBagConstraints);

                fileAlbumArtistSortLabel.setText("Sort name:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(fileAlbumArtistSortLabel, gridBagConstraints);

                fileAlbumArtistSortValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(fileAlbumArtistSortValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.SOUTHEAST;
                gridBagConstraints.weightx = 2.0;
                metadataPanel.add(albumArtistPanel, gridBagConstraints);

                getContentPane().add(metadataPanel, java.awt.BorderLayout.SOUTH);

                topPanel.setLayout(new java.awt.GridBagLayout());

                filterLabel.setText("Filter:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(filterLabel, gridBagConstraints);

                filterTextField.setMinimumSize(new java.awt.Dimension(128, 25));
                filterTextField.setPreferredSize(new java.awt.Dimension(128, 25));
                filterTextField.addKeyListener(new java.awt.event.KeyAdapter() {
                        public void keyPressed(java.awt.event.KeyEvent evt) {
                                filterTextFieldKeyPressed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(filterTextField, gridBagConstraints);

                updateButton.setMnemonic('U');
                updateButton.setText("Update");
                updateButton.setFocusable(false);
                updateButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                updateButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(updateButton, gridBagConstraints);

                openButton.setMnemonic('C');
                openButton.setText("Connect");
                openButton.setFocusable(false);
                openButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                openButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 5;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(openButton, gridBagConstraints);

                quitButton.setMnemonic('Q');
                quitButton.setText("Quit");
                quitButton.setFocusable(false);
                quitButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                quitButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 6;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(quitButton, gridBagConstraints);

                locutusProgressLabel.setText("Locutus progress:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(locutusProgressLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 4;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(locutusProgressBar, gridBagConstraints);

                getContentPane().add(topPanel, java.awt.BorderLayout.NORTH);

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
			tabPane.setSelectedComponent(matching);
			matching.updateTree();
		} catch (ClassNotFoundException e) {
			JOptionPane.showMessageDialog(this, e);
			e.printStackTrace();
		} catch (SQLException e) {
			JOptionPane.showMessageDialog(this, e);
			e.printStackTrace();
		}
	}//GEN-LAST:event_connectButtonActionPerformed

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

	private void openButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_openButtonActionPerformed
		connectFrame.setVisible(true);
	}//GEN-LAST:event_openButtonActionPerformed

	private void quitButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_quitButtonActionPerformed
		try {
			Database.disconnect();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		this.dispose();
		System.exit(0);
	}//GEN-LAST:event_quitButtonActionPerformed

	private void fileSaveButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_fileSaveButtonActionPerformed
		// TODO add your handling code here:
	}//GEN-LAST:event_fileSaveButtonActionPerformed

	private void updateButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_updateButtonActionPerformed
		updateButton.setText("Updating...");
		Component active = tabPane.getSelectedComponent();
		if (active != null) {
			/* hide & show visible component to trigger formComponentShown().
			 * XXX: this is a hack, fix it later */
			active.setVisible(false);
			active.setVisible(true);
		}
		updateButton.setText("Update");
	}//GEN-LAST:event_updateButtonActionPerformed

	private void filterTextFieldKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_filterTextFieldKeyPressed
		if (evt.getKeyCode() == KeyEvent.VK_ENTER)
			updateButton.doClick();
	}//GEN-LAST:event_filterTextFieldKeyPressed

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
        private javax.swing.JPanel albumArtistPanel;
        private javax.swing.JPanel albumPanel;
        private javax.swing.JPanel artistPanel;
        private javax.swing.JButton cancelButton;
        private javax.swing.JButton connectButton;
        private javax.swing.JFrame connectFrame;
        private javax.swing.JLabel databaseLabel;
        private javax.swing.JTextField databaseTextField;
        private net.exent.locutus.gui.Detached detached;
        private javax.swing.JComboBox driverCombo;
        private javax.swing.JLabel driverLabel;
        private static javax.swing.JLabel fileAlbumArtistLabel;
        private static javax.swing.JLabel fileAlbumArtistMBIDLabel;
        private static javax.swing.JTextField fileAlbumArtistMBIDValue;
        private static javax.swing.JLabel fileAlbumArtistSortLabel;
        private static javax.swing.JTextField fileAlbumArtistSortValue;
        private static javax.swing.JTextField fileAlbumArtistValue;
        private static javax.swing.JLabel fileAlbumLabel;
        private static javax.swing.JLabel fileAlbumMBIDLabel;
        private static javax.swing.JTextField fileAlbumMBIDValue;
        private static javax.swing.JTextField fileAlbumValue;
        private static javax.swing.JLabel fileArtistLabel;
        private static javax.swing.JLabel fileArtistMBIDLabel;
        private static javax.swing.JTextField fileArtistMBIDValue;
        private static javax.swing.JLabel fileArtistSortLabel;
        private static javax.swing.JTextField fileArtistSortValue;
        private static javax.swing.JTextField fileArtistValue;
        private static javax.swing.JLabel fileBitrateLabel;
        private static javax.swing.JLabel fileBitrateValue;
        private static javax.swing.JLabel fileChannelsLabel;
        private static javax.swing.JLabel fileChannelsValue;
        private static javax.swing.JCheckBox fileDuplicate;
        private static javax.swing.JLabel fileDurationLabel;
        private static javax.swing.JLabel fileDurationValue;
        private static javax.swing.JLabel fileFileIDLabel;
        private static javax.swing.JTextField fileFileIDValue;
        private static javax.swing.JLabel fileFilenameLabel;
        private static javax.swing.JLabel fileGenreLabel;
        private static javax.swing.JTextField fileGenreValue;
        private static javax.swing.JLabel fileGroupLabel;
        private static javax.swing.JTextField fileGroupValue;
        private static javax.swing.JCheckBox fileModified;
        private static javax.swing.JCheckBox filePinned;
        private static javax.swing.JLabel fileReleasedLabel;
        private static javax.swing.JTextField fileReleasedValue;
        private static javax.swing.JLabel fileSamplerateLabel;
        private static javax.swing.JLabel fileSamplerateValue;
        private static javax.swing.JButton fileSaveButton;
        private static javax.swing.JLabel fileTitleLabel;
        private static javax.swing.JTextField fileTitleValue;
        private static javax.swing.JLabel fileTrackIDLabel;
        private static javax.swing.JTextField fileTrackIDValue;
        private static javax.swing.JLabel fileTrackMBIDLabel;
        private static javax.swing.JTextField fileTrackMBIDValue;
        private static javax.swing.JLabel fileTracknumberLabel;
        private static javax.swing.JTextField fileTracknumberValue;
        private javax.swing.JLabel filterLabel;
        private static javax.swing.JTextField filterTextField;
        private javax.swing.JLabel hostLabel;
        private javax.swing.JTextField hostTextField;
        private javax.swing.JProgressBar locutusProgressBar;
        private javax.swing.JLabel locutusProgressLabel;
        private net.exent.locutus.gui.Matching matching;
        private static javax.swing.JPanel metadataPanel;
        private javax.swing.JPanel miscPanel;
        private javax.swing.JButton openButton;
        private javax.swing.JLabel passwordLabel;
        private javax.swing.JPasswordField passwordPasswordField;
        private javax.swing.JButton quitButton;
        private net.exent.locutus.gui.Settings settings;
        private javax.swing.JTabbedPane tabPane;
        private javax.swing.JPanel topPanel;
        private javax.swing.JPanel trackPanel;
        private javax.swing.JButton updateButton;
        private javax.swing.JLabel usernameLabel;
        private javax.swing.JTextField usernameTextField;
        // End of variables declaration//GEN-END:variables
}
