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
import java.util.List;
import javax.swing.JOptionPane;
import javax.swing.ToolTipManager;
import net.exent.locutus.data.Metafile;
import net.exent.locutus.database.Database;
import net.exent.locutus.thread.StatusPoller;

/**
 *
 * @author canidae
 */
public class Locutus extends javax.swing.JFrame {

	private static StatusPoller statusPoller = new StatusPoller();
	private static List<Metafile> selected_metafiles;

	/** Creates new form Locutus */
	public Locutus() {
		initComponents();
		/* make tooltips stay a bit longer */
		ToolTipManager.sharedInstance().setDismissDelay(90000);
		statusPoller.start();
	}

	public static void setProgress(double progress, String status) {
		progressBar.setValue((int) (progress * 1000));
		progressLabel.setText(status);
	}

	public static String getFilter() {
		return filterTextField.getText();
	}

	public static void setSelectedMetadatafiles(List<Metafile> files) {
		selected_metafiles = files;
		if (files.size() <= 0)
			return;

		clearMetadata();
		if (files.size() > 1)
			fileFilenameLabel.setText("<" + files.size() + " files selected>");
		else
			fileFilenameLabel.setText(files.get(0).getFilename());

		boolean first = true;
		for (Metafile file : files) {
			/* misc panel */
			if (first || (!"".equals(file.getGroup()) && groupValue.getText().equals(file.getGroup())))
				groupValue.setText(file.getGroup());
			else
				groupValue.setText("");
			if (file.getFileID() > 0 && (first || (!"".equals("" + file.getFileID()) && fileIDValue.getText().equals("" + file.getFileID()))))
				fileIDValue.setText("" + file.getFileID());
			else
				fileIDValue.setText("");
			if (file.getTrackID() > 0 && (first || (!"".equals("" + file.getTrackID()) && trackIDValue.getText().equals("" + file.getTrackID()))))
				trackIDValue.setText("" + file.getTrackID());
			else
				trackIDValue.setText("");
			if (first || (!"".equals("" + file.getDuration()) && durationValue.getText().equals("" + file.getDuration())))
				durationValue.setText("" + file.getDuration());
			else
				durationValue.setText("");
			if (first || (!"".equals("" + file.getBitrate()) && bitrateValue.getText().equals("" + file.getBitrate())))
				bitrateValue.setText("" + file.getBitrate());
			else
				bitrateValue.setText("");
			if (first || (!"".equals("" + file.getChannels()) && channelsValue.getText().equals("" + file.getChannels())))
				channelsValue.setText("" + file.getChannels());
			else
				channelsValue.setText("");
			if (first || (!"".equals("" + file.getSamplerate()) && samplerateValue.getText().equals("" + file.getSamplerate())))
				samplerateValue.setText("" + file.getSamplerate());
			else
				samplerateValue.setText("");
			if (first || !file.isModified())
				modifiedCheckBox.setSelected(file.isModified());
			if (first || !file.isDuplicate())
				duplicateCheckBox.setSelected(file.isDuplicate());
			if (first || !file.isPinned())
				pinnedCheckBox.setSelected(file.isPinned());

			/* artist panel */
			if (first || (artistCheckBox.isSelected() && artistValue.getText().equals(file.getArtist()))) {
				artistCheckBox.setSelected(true);
				artistValue.setEditable(true);
				artistValue.setText(file.getArtist());
			} else {
				artistCheckBox.setSelected(false);
				artistValue.setEditable(false);
				artistValue.setText("");
			}
			if (first || (artistSortCheckBox.isSelected() && artistSortValue.getText().equals(file.getArtistSortName()))) {
				artistSortCheckBox.setSelected(true);
				artistSortValue.setEditable(true);
				artistSortValue.setText(file.getArtistSortName());
			} else {
				artistSortCheckBox.setSelected(false);
				artistSortValue.setEditable(false);
				artistSortValue.setText("");
			}
			if (first || (albumMBIDCheckBox.isSelected() && artistMBIDValue.getText().equals(file.getArtistMBID()))) {
				artistMBIDCheckBox.setSelected(true);
				artistMBIDValue.setEditable(true);
				artistMBIDValue.setText(file.getArtistMBID());
			} else {
				artistMBIDCheckBox.setSelected(false);
				artistMBIDValue.setEditable(false);
				artistMBIDValue.setText("");
			}

			/* track panel */
			if (first || (titleCheckBox.isSelected() && titleValue.getText().equals(file.getTitle()))) {
				titleCheckBox.setSelected(true);
				titleValue.setEditable(true);
				titleValue.setText(file.getTitle());
			} else {
				titleCheckBox.setSelected(false);
				titleValue.setEditable(false);
				titleValue.setText("");
			}
			if (first || (tracknumberCheckBox.isSelected() && tracknumberValue.getText().equals("" + file.getTracknumber()))) {
				tracknumberCheckBox.setSelected(true);
				tracknumberValue.setEditable(true);
				tracknumberValue.setText("" + file.getTracknumber());
			} else {
				tracknumberCheckBox.setSelected(false);
				tracknumberValue.setEditable(false);
				tracknumberValue.setText("");
			}
			if (first || (genreCheckBox.isSelected() && genreValue.getText().equals(file.getGenre()))) {
				genreCheckBox.setSelected(true);
				genreValue.setEditable(true);
				genreValue.setText(file.getGenre());
			} else {
				genreCheckBox.setSelected(false);
				genreValue.setEditable(false);
				genreValue.setText("");
			}
			if (first || (trackMBIDCheckBox.isSelected() && trackMBIDValue.getText().equals(file.getTrackMBID()))) {
				trackMBIDCheckBox.setSelected(true);
				trackMBIDValue.setEditable(true);
				trackMBIDValue.setText(file.getTrackMBID());
			} else {
				trackMBIDCheckBox.setSelected(false);
				trackMBIDValue.setEditable(false);
				trackMBIDValue.setText("");
			}

			/* album panel */
			if (first || (albumCheckBox.isSelected() && albumValue.getText().equals(file.getAlbum()))) {
				albumCheckBox.setSelected(true);
				albumValue.setEditable(true);
				albumValue.setText(file.getAlbum());
			} else {
				albumCheckBox.setSelected(false);
				albumValue.setEditable(false);
				albumValue.setText("");
			}
			if (first || (releasedCheckBox.isSelected() && releasedValue.getText().equals(file.getReleased()))) {
				releasedCheckBox.setSelected(true);
				releasedValue.setEditable(true);
				releasedValue.setText(file.getReleased());
			} else {
				releasedCheckBox.setSelected(false);
				releasedValue.setEditable(false);
				releasedValue.setText("");
			}
			if (first || (albumMBIDCheckBox.isSelected() && albumMBIDValue.getText().equals(file.getAlbumMBID()))) {
				albumMBIDCheckBox.setSelected(true);
				albumMBIDValue.setEditable(true);
				albumMBIDValue.setText(file.getAlbumMBID());
			} else {
				albumMBIDCheckBox.setSelected(false);
				albumMBIDValue.setEditable(false);
				albumMBIDValue.setText("");
			}

			/* album artist panel */
			if (first || (albumArtistCheckBox.isSelected() && albumArtistValue.getText().equals(file.getAlbumArtist()))) {
				albumArtistCheckBox.setSelected(true);
				albumArtistValue.setEditable(true);
				albumArtistValue.setText(file.getAlbumArtist());
			} else {
				albumArtistCheckBox.setSelected(false);
				albumArtistValue.setEditable(false);
				albumArtistValue.setText("");
			}
			if (first || (albumArtistSortCheckBox.isSelected() && albumArtistSortValue.getText().equals(file.getAlbumArtistSortName()))) {
				albumArtistSortCheckBox.setSelected(true);
				albumArtistSortValue.setEditable(true);
				albumArtistSortValue.setText(file.getAlbumArtistSortName());
			} else {
				albumArtistSortCheckBox.setSelected(false);
				albumArtistSortValue.setEditable(false);
				albumArtistSortValue.setText("");
			}
			if (first || (albumArtistMBIDCheckBox.isSelected() && albumArtistMBIDValue.getText().equals(file.getAlbumArtistMBID()))) {
				albumArtistMBIDCheckBox.setSelected(true);
				albumArtistMBIDValue.setEditable(true);
				albumArtistMBIDValue.setText(file.getAlbumArtistMBID());
			} else {
				albumArtistMBIDCheckBox.setSelected(false);
				albumArtistMBIDValue.setEditable(false);
				albumArtistMBIDValue.setText("");
			}

			first = false;
		}
	}

	public static void clearMetadata() {
		/* filename */
		fileFilenameLabel.setText("<no files selected>");

		/* misc panel */
		groupValue.setText("");
		fileIDValue.setText("");
		trackIDValue.setText("");
		durationValue.setText("");
		bitrateValue.setText("");
		channelsValue.setText("");
		samplerateValue.setText("");
		modifiedCheckBox.setSelected(false);
		duplicateCheckBox.setSelected(false);
		pinnedCheckBox.setSelected(false);

		/* artist panel */
		artistValue.setText("");
		artistSortValue.setText("");
		artistMBIDValue.setText("");

		/* track panel */
		titleValue.setText("");
		tracknumberValue.setText("");
		genreValue.setText("");
		trackMBIDValue.setText("");

		/* album panel */
		albumValue.setText("");
		releasedValue.setText("");
		albumMBIDValue.setText("");

		/* album artist panel */
		albumArtistValue.setText("");
		albumArtistSortValue.setText("");
		albumArtistMBIDValue.setText("");
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
                abortButton = new javax.swing.JButton();
                databaseLabel = new javax.swing.JLabel();
                databaseTextField = new javax.swing.JTextField();
                passwordPasswordField = new javax.swing.JPasswordField();
                topPanel = new javax.swing.JPanel();
                filterLabel = new javax.swing.JLabel();
                filterTextField = new javax.swing.JTextField();
                updateButton = new javax.swing.JButton();
                progressBar = new javax.swing.JProgressBar();
                progressLabel = new javax.swing.JLabel();
                openButton = new javax.swing.JButton();
                quitButton = new javax.swing.JButton();
                tabPane = new javax.swing.JTabbedPane();
                matching = new net.exent.locutus.gui.Matching();
                uncompared = new net.exent.locutus.gui.Uncompared();
                settings = new net.exent.locutus.gui.Settings();
                help = new net.exent.locutus.gui.Help();
                metadataPanel = new javax.swing.JPanel();
                fileFilenameLabel = new javax.swing.JLabel();
                miscPanel = new javax.swing.JPanel();
                groupLabel = new javax.swing.JLabel();
                groupValue = new javax.swing.JTextField();
                fileIDLabel = new javax.swing.JLabel();
                fileIDValue = new javax.swing.JTextField();
                trackIDLabel = new javax.swing.JLabel();
                trackIDValue = new javax.swing.JTextField();
                durationLabel = new javax.swing.JLabel();
                durationValue = new javax.swing.JLabel();
                bitrateLabel = new javax.swing.JLabel();
                bitrateValue = new javax.swing.JLabel();
                channelsLabel = new javax.swing.JLabel();
                channelsValue = new javax.swing.JLabel();
                samplerateLabel = new javax.swing.JLabel();
                samplerateValue = new javax.swing.JLabel();
                modifiedCheckBox = new javax.swing.JCheckBox();
                duplicateCheckBox = new javax.swing.JCheckBox();
                pinnedCheckBox = new javax.swing.JCheckBox();
                setMetadataButton = new javax.swing.JButton();
                artistPanel = new javax.swing.JPanel();
                artistCheckBox = new javax.swing.JCheckBox();
                artistValue = new javax.swing.JTextField();
                artistSortCheckBox = new javax.swing.JCheckBox();
                artistSortValue = new javax.swing.JTextField();
                artistMBIDCheckBox = new javax.swing.JCheckBox();
                artistMBIDValue = new javax.swing.JTextField();
                trackPanel = new javax.swing.JPanel();
                titleCheckBox = new javax.swing.JCheckBox();
                titleValue = new javax.swing.JTextField();
                tracknumberCheckBox = new javax.swing.JCheckBox();
                tracknumberValue = new javax.swing.JTextField();
                genreCheckBox = new javax.swing.JCheckBox();
                genreValue = new javax.swing.JTextField();
                trackMBIDCheckBox = new javax.swing.JCheckBox();
                trackMBIDValue = new javax.swing.JTextField();
                albumPanel = new javax.swing.JPanel();
                albumCheckBox = new javax.swing.JCheckBox();
                albumValue = new javax.swing.JTextField();
                releasedCheckBox = new javax.swing.JCheckBox();
                releasedValue = new javax.swing.JTextField();
                albumMBIDCheckBox = new javax.swing.JCheckBox();
                albumMBIDValue = new javax.swing.JTextField();
                albumArtistPanel = new javax.swing.JPanel();
                albumArtistCheckBox = new javax.swing.JCheckBox();
                albumArtistValue = new javax.swing.JTextField();
                albumArtistSortCheckBox = new javax.swing.JCheckBox();
                albumArtistSortValue = new javax.swing.JTextField();
                albumArtistMBIDCheckBox = new javax.swing.JCheckBox();
                albumArtistMBIDValue = new javax.swing.JTextField();

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

                connectButton.setMnemonic('C');
                connectButton.setText("Connect");
                connectButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                connectButtonActionPerformed(evt);
                        }
                });

                abortButton.setMnemonic('A');
                abortButton.setText("Abort");
                abortButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                abortButtonActionPerformed(evt);
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
                                                .addComponent(abortButton, javax.swing.GroupLayout.DEFAULT_SIZE, 115, Short.MAX_VALUE))
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
                                        .addComponent(abortButton, javax.swing.GroupLayout.PREFERRED_SIZE, 42, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addContainerGap())
                );

                setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
                setTitle("Locutus");

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

                progressBar.setMaximum(1000);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(progressBar, gridBagConstraints);

                progressLabel.setText("Not connected");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 4;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                topPanel.add(progressLabel, gridBagConstraints);

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

                getContentPane().add(topPanel, java.awt.BorderLayout.NORTH);

                tabPane.setMinimumSize(new java.awt.Dimension(400, 200));
                tabPane.setPreferredSize(new java.awt.Dimension(400, 200));
                tabPane.addTab("Matching", matching);
                tabPane.addTab("Uncompared", uncompared);

                settings.setMinimumSize(new java.awt.Dimension(400, 200));
                tabPane.addTab("Settings", settings);
                tabPane.addTab("Help", help);

                getContentPane().add(tabPane, java.awt.BorderLayout.CENTER);

                metadataPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Metadata"));
                metadataPanel.setLayout(new java.awt.GridBagLayout());

                fileFilenameLabel.setText("<no files selected>");
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

                groupLabel.setText("Group:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.gridwidth = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(groupLabel, gridBagConstraints);

                groupValue.setEditable(false);
                groupValue.setToolTipText("<html>The group the file[s] belong to.<br />\nThe value for this field is automatically generated by the daemon using audio format, samplerate, channels and album title or path if album title is not set.<br />\nIf you wish to group files together manually you should write in the same album title for all of them (you still won't be able to do anything about format, samplerate or channels, though).</html>");
                groupValue.setMaximumSize(new java.awt.Dimension(256, 25));
                groupValue.setMinimumSize(new java.awt.Dimension(256, 25));
                groupValue.setPreferredSize(new java.awt.Dimension(256, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.gridwidth = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(groupValue, gridBagConstraints);

                fileIDLabel.setText("File ID:");
                fileIDLabel.setMaximumSize(new java.awt.Dimension(63, 17));
                fileIDLabel.setMinimumSize(new java.awt.Dimension(63, 17));
                fileIDLabel.setPreferredSize(new java.awt.Dimension(63, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileIDLabel, gridBagConstraints);

                fileIDValue.setEditable(false);
                fileIDValue.setMaximumSize(new java.awt.Dimension(64, 25));
                fileIDValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileIDValue.setPreferredSize(new java.awt.Dimension(64, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileIDValue, gridBagConstraints);

                trackIDLabel.setText("Track ID:");
                trackIDLabel.setMaximumSize(new java.awt.Dimension(79, 17));
                trackIDLabel.setMinimumSize(new java.awt.Dimension(79, 17));
                trackIDLabel.setPreferredSize(new java.awt.Dimension(79, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(trackIDLabel, gridBagConstraints);

                trackIDValue.setEditable(false);
                trackIDValue.setMaximumSize(new java.awt.Dimension(64, 25));
                trackIDValue.setMinimumSize(new java.awt.Dimension(64, 25));
                trackIDValue.setPreferredSize(new java.awt.Dimension(64, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(trackIDValue, gridBagConstraints);

                durationLabel.setText("Duration:");
                durationLabel.setMaximumSize(new java.awt.Dimension(63, 17));
                durationLabel.setMinimumSize(new java.awt.Dimension(63, 17));
                durationLabel.setPreferredSize(new java.awt.Dimension(63, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(durationLabel, gridBagConstraints);

                durationValue.setMinimumSize(new java.awt.Dimension(64, 17));
                durationValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(durationValue, gridBagConstraints);

                bitrateLabel.setText("Bitrate:");
                bitrateLabel.setMaximumSize(new java.awt.Dimension(79, 17));
                bitrateLabel.setMinimumSize(new java.awt.Dimension(79, 17));
                bitrateLabel.setPreferredSize(new java.awt.Dimension(79, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(bitrateLabel, gridBagConstraints);

                bitrateValue.setMinimumSize(new java.awt.Dimension(64, 17));
                bitrateValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(bitrateValue, gridBagConstraints);

                channelsLabel.setText("Channels:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(channelsLabel, gridBagConstraints);

                channelsValue.setMinimumSize(new java.awt.Dimension(64, 17));
                channelsValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(channelsValue, gridBagConstraints);

                samplerateLabel.setText("Samplerate:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(samplerateLabel, gridBagConstraints);

                samplerateValue.setMinimumSize(new java.awt.Dimension(64, 17));
                samplerateValue.setPreferredSize(new java.awt.Dimension(64, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(samplerateValue, gridBagConstraints);

                modifiedCheckBox.setText("Modified");
                modifiedCheckBox.setToolTipText("Whether the file[s] are modified by the user since the last time the daemon processed the file[s].");
                modifiedCheckBox.setEnabled(false);
                modifiedCheckBox.setFocusable(false);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 5;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(modifiedCheckBox, gridBagConstraints);

                duplicateCheckBox.setText("Duplicate");
                duplicateCheckBox.setToolTipText("Whether the file[s] are duplicates.");
                duplicateCheckBox.setEnabled(false);
                duplicateCheckBox.setFocusable(false);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 5;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(duplicateCheckBox, gridBagConstraints);

                pinnedCheckBox.setText("Pinned");
                pinnedCheckBox.setToolTipText("<html>A pinned file will have preference above other duplicates regardless of quality.<br />\nFor example, you got an album with MP3-files and then 1 extra file from the same album, but in FLAC format.<br />\nMost likely the FLAC will appear in the output directory while the duplicate MP3 will be placed in the duplicate directory.<br />\nIf you pin the duplicate MP3 then the FLAC will be placed in the duplicate directory and the MP3 in the output directory.<br />\nIf you pin multiple duplicates the behaviour is undefined, it's usually better to delete the duplicate you don't want.</html>");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 6;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(pinnedCheckBox, gridBagConstraints);

                setMetadataButton.setMnemonic('S');
                setMetadataButton.setText("Set metadata");
                setMetadataButton.setFocusable(false);
                setMetadataButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                setMetadataButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 6;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                miscPanel.add(setMetadataButton, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.gridheight = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.SOUTHWEST;
                metadataPanel.add(miscPanel, gridBagConstraints);

                artistPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Artist"));
                artistPanel.setLayout(new java.awt.GridBagLayout());

                artistCheckBox.setSelected(true);
                artistCheckBox.setText("Name:");
                artistCheckBox.setToolTipText("When checked, field will be saved");
                artistCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                artistCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                artistCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                artistCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                artistCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(artistCheckBox, gridBagConstraints);

                artistValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(artistValue, gridBagConstraints);

                artistSortCheckBox.setSelected(true);
                artistSortCheckBox.setText("Sort name:");
                artistSortCheckBox.setToolTipText("When checked, field will be saved");
                artistSortCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                artistSortCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(artistSortCheckBox, gridBagConstraints);

                artistSortValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(artistSortValue, gridBagConstraints);

                artistMBIDCheckBox.setSelected(true);
                artistMBIDCheckBox.setText("MBID:");
                artistMBIDCheckBox.setToolTipText("When checked, field will be saved");
                artistMBIDCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                artistMBIDCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                artistMBIDCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                artistMBIDCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                artistMBIDCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(artistMBIDCheckBox, gridBagConstraints);

                artistMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(artistMBIDValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.weightx = 1.0;
                metadataPanel.add(artistPanel, gridBagConstraints);

                trackPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Track"));
                trackPanel.setLayout(new java.awt.GridBagLayout());

                titleCheckBox.setSelected(true);
                titleCheckBox.setText("Title:");
                titleCheckBox.setToolTipText("When checked, field will be saved");
                titleCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                titleCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                titleCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                titleCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                titleCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(titleCheckBox, gridBagConstraints);

                titleValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(titleValue, gridBagConstraints);

                tracknumberCheckBox.setSelected(true);
                tracknumberCheckBox.setText("Tracknum:");
                tracknumberCheckBox.setToolTipText("When checked, field will be saved");
                tracknumberCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                tracknumberCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                tracknumberCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                tracknumberCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                tracknumberCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(tracknumberCheckBox, gridBagConstraints);

                tracknumberValue.setMaximumSize(new java.awt.Dimension(32, 25));
                tracknumberValue.setMinimumSize(new java.awt.Dimension(32, 25));
                tracknumberValue.setPreferredSize(new java.awt.Dimension(32, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(tracknumberValue, gridBagConstraints);

                genreCheckBox.setSelected(true);
                genreCheckBox.setText("Genre:");
                genreCheckBox.setToolTipText("When checked, field will be saved");
                genreCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                genreCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(genreCheckBox, gridBagConstraints);

                genreValue.setPreferredSize(new java.awt.Dimension(64, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 3;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(genreValue, gridBagConstraints);

                trackMBIDCheckBox.setSelected(true);
                trackMBIDCheckBox.setText("MBID:");
                trackMBIDCheckBox.setToolTipText("When checked, field will be saved");
                trackMBIDCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                trackMBIDCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                trackMBIDCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                trackMBIDCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                trackMBIDCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(trackMBIDCheckBox, gridBagConstraints);

                trackMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(trackMBIDValue, gridBagConstraints);

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

                albumCheckBox.setSelected(true);
                albumCheckBox.setText("Title:");
                albumCheckBox.setToolTipText("When checked, field will be saved");
                albumCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                albumCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                albumCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                albumCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                albumCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(albumCheckBox, gridBagConstraints);

                albumValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(albumValue, gridBagConstraints);

                releasedCheckBox.setSelected(true);
                releasedCheckBox.setText("Released:");
                releasedCheckBox.setToolTipText("When checked, field will be saved");
                releasedCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                releasedCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                releasedCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                releasedCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                releasedCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(releasedCheckBox, gridBagConstraints);

                releasedValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(releasedValue, gridBagConstraints);

                albumMBIDCheckBox.setSelected(true);
                albumMBIDCheckBox.setText("MBID:");
                albumMBIDCheckBox.setToolTipText("When checked, field will be saved");
                albumMBIDCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                albumMBIDCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                albumMBIDCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                albumMBIDCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                albumMBIDCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(albumMBIDCheckBox, gridBagConstraints);

                albumMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumPanel.add(albumMBIDValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.weightx = 2.0;
                metadataPanel.add(albumPanel, gridBagConstraints);

                albumArtistPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Album artist"));
                albumArtistPanel.setLayout(new java.awt.GridBagLayout());

                albumArtistCheckBox.setSelected(true);
                albumArtistCheckBox.setText("Name:");
                albumArtistCheckBox.setToolTipText("When checked, field will be saved");
                albumArtistCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                albumArtistCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                albumArtistCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                albumArtistCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                albumArtistCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(albumArtistCheckBox, gridBagConstraints);

                albumArtistValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(albumArtistValue, gridBagConstraints);

                albumArtistSortCheckBox.setSelected(true);
                albumArtistSortCheckBox.setText("Sort name:");
                albumArtistSortCheckBox.setToolTipText("When checked, field will be saved");
                albumArtistSortCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                albumArtistSortCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(albumArtistSortCheckBox, gridBagConstraints);

                albumArtistSortValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(albumArtistSortValue, gridBagConstraints);

                albumArtistMBIDCheckBox.setSelected(true);
                albumArtistMBIDCheckBox.setText("MBID:");
                albumArtistMBIDCheckBox.setToolTipText("When checked, field will be saved");
                albumArtistMBIDCheckBox.setMaximumSize(new java.awt.Dimension(95, 21));
                albumArtistMBIDCheckBox.setMinimumSize(new java.awt.Dimension(95, 21));
                albumArtistMBIDCheckBox.setPreferredSize(new java.awt.Dimension(95, 21));
                albumArtistMBIDCheckBox.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                albumArtistMBIDCheckBoxActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(albumArtistMBIDCheckBox, gridBagConstraints);

                albumArtistMBIDValue.setPreferredSize(new java.awt.Dimension(245, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                albumArtistPanel.add(albumArtistMBIDValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.SOUTHEAST;
                gridBagConstraints.weightx = 2.0;
                metadataPanel.add(albumArtistPanel, gridBagConstraints);

                getContentPane().add(metadataPanel, java.awt.BorderLayout.SOUTH);

                pack();
        }// </editor-fold>//GEN-END:initComponents

	private void connectButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_connectButtonActionPerformed
		try {
			setProgress(0.0, "Not connected");
			connectFrame.setVisible(false);
			Database.disconnect();
			String db = driverCombo.getSelectedItem().toString();
			db += hostTextField.getText();
			db += "/";
			db += databaseTextField.getText();
			Database.connectPostgreSQL(db, usernameTextField.getText(), new String(passwordPasswordField.getPassword()));
			tabPane.setSelectedComponent(matching);
			matching.updateTree();
			statusPoller.checkStatus();
		} catch (ClassNotFoundException e) {
			JOptionPane.showMessageDialog(this, e);
			e.printStackTrace();
		} catch (SQLException e) {
			JOptionPane.showMessageDialog(this, e);
			e.printStackTrace();
		}
	}//GEN-LAST:event_connectButtonActionPerformed

	private void abortButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_abortButtonActionPerformed
		connectFrame.setVisible(false);
	}//GEN-LAST:event_abortButtonActionPerformed

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
		statusPoller.exit();
		try {
			Database.disconnect();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		this.dispose();
		System.exit(0);
	}//GEN-LAST:event_quitButtonActionPerformed

	private void setMetadataButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_setMetadataButtonActionPerformed
		for (Metafile file : selected_metafiles) {
			/* artist */
			if (artistCheckBox.isSelected())
				file.setArtist(artistValue.getText());
			if (artistSortCheckBox.isSelected())
				file.setArtistSortName(artistSortValue.getText());
			if (artistMBIDCheckBox.isSelected())
				file.setArtistMBID(artistMBIDValue.getText());

			/* track */
			if (titleCheckBox.isSelected())
				file.setTitle(titleValue.getText());
			try {
				if (tracknumberCheckBox.isSelected())
					file.setTracknumber(Integer.parseInt(tracknumberValue.getText()));
			} catch (NumberFormatException e) {
				e.printStackTrace();
			}
			if (genreCheckBox.isSelected())
				file.setGenre(genreValue.getText());
			if (trackMBIDCheckBox.isSelected())
				file.setTrackMBID(trackMBIDValue.getText());

			/* album */
			if (albumCheckBox.isSelected())
				file.setAlbum(albumValue.getText());
			if (releasedCheckBox.isSelected())
				file.setReleased(releasedValue.getText());
			if (albumMBIDCheckBox.isSelected())
				file.setAlbumMBID(albumMBIDValue.getText());

			/* album artist */
			if (albumArtistCheckBox.isSelected())
				file.setAlbumArtist(albumArtistValue.getText());
			if (albumArtistSortCheckBox.isSelected())
				file.setAlbumArtistSortName(albumArtistSortValue.getText());
			if (albumArtistMBIDCheckBox.isSelected())
				file.setAlbumArtistMBID(albumArtistMBIDValue.getText());

			/* pinned */
			file.setPinned(pinnedCheckBox.isSelected());

			/* set status to SAVE_METADATA */
			file.setStatus(Metafile.SAVE_METADATA);
		}
		matching.repaint();
	}//GEN-LAST:event_setMetadataButtonActionPerformed

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

	private void artistCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_artistCheckBoxActionPerformed
		artistValue.setEditable(artistCheckBox.isSelected());
	}//GEN-LAST:event_artistCheckBoxActionPerformed

	private void artistSortCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_artistSortCheckBoxActionPerformed
		artistSortValue.setEditable(artistSortCheckBox.isSelected());
	}//GEN-LAST:event_artistSortCheckBoxActionPerformed

	private void artistMBIDCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_artistMBIDCheckBoxActionPerformed
		artistMBIDValue.setEditable(artistMBIDCheckBox.isSelected());
	}//GEN-LAST:event_artistMBIDCheckBoxActionPerformed

	private void titleCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_titleCheckBoxActionPerformed
		titleValue.setEditable(titleCheckBox.isSelected());
	}//GEN-LAST:event_titleCheckBoxActionPerformed

	private void tracknumberCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_tracknumberCheckBoxActionPerformed
		tracknumberValue.setEditable(tracknumberCheckBox.isSelected());
	}//GEN-LAST:event_tracknumberCheckBoxActionPerformed

	private void genreCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_genreCheckBoxActionPerformed
		genreValue.setEditable(genreCheckBox.isSelected());
	}//GEN-LAST:event_genreCheckBoxActionPerformed

	private void trackMBIDCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_trackMBIDCheckBoxActionPerformed
		trackMBIDValue.setEditable(trackMBIDCheckBox.isSelected());
	}//GEN-LAST:event_trackMBIDCheckBoxActionPerformed

	private void albumCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_albumCheckBoxActionPerformed
		albumValue.setEditable(albumCheckBox.isSelected());
	}//GEN-LAST:event_albumCheckBoxActionPerformed

	private void releasedCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_releasedCheckBoxActionPerformed
		releasedValue.setEditable(releasedCheckBox.isSelected());
	}//GEN-LAST:event_releasedCheckBoxActionPerformed

	private void albumMBIDCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_albumMBIDCheckBoxActionPerformed
		albumMBIDValue.setEditable(albumMBIDCheckBox.isSelected());
	}//GEN-LAST:event_albumMBIDCheckBoxActionPerformed

	private void albumArtistCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_albumArtistCheckBoxActionPerformed
		albumArtistValue.setEditable(albumArtistCheckBox.isSelected());
	}//GEN-LAST:event_albumArtistCheckBoxActionPerformed

	private void albumArtistSortCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_albumArtistSortCheckBoxActionPerformed
		albumArtistSortValue.setEditable(albumArtistSortCheckBox.isSelected());
	}//GEN-LAST:event_albumArtistSortCheckBoxActionPerformed

	private void albumArtistMBIDCheckBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_albumArtistMBIDCheckBoxActionPerformed
		albumArtistMBIDValue.setEditable(albumArtistMBIDCheckBox.isSelected());
	}//GEN-LAST:event_albumArtistMBIDCheckBoxActionPerformed

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
        private javax.swing.JButton abortButton;
        private static javax.swing.JCheckBox albumArtistCheckBox;
        private static javax.swing.JCheckBox albumArtistMBIDCheckBox;
        private static javax.swing.JTextField albumArtistMBIDValue;
        private javax.swing.JPanel albumArtistPanel;
        private static javax.swing.JCheckBox albumArtistSortCheckBox;
        private static javax.swing.JTextField albumArtistSortValue;
        private static javax.swing.JTextField albumArtistValue;
        private static javax.swing.JCheckBox albumCheckBox;
        private static javax.swing.JCheckBox albumMBIDCheckBox;
        private static javax.swing.JTextField albumMBIDValue;
        private javax.swing.JPanel albumPanel;
        private static javax.swing.JTextField albumValue;
        private static javax.swing.JCheckBox artistCheckBox;
        private static javax.swing.JCheckBox artistMBIDCheckBox;
        private static javax.swing.JTextField artistMBIDValue;
        private javax.swing.JPanel artistPanel;
        private static javax.swing.JCheckBox artistSortCheckBox;
        private static javax.swing.JTextField artistSortValue;
        private static javax.swing.JTextField artistValue;
        private static javax.swing.JLabel bitrateLabel;
        private static javax.swing.JLabel bitrateValue;
        private static javax.swing.JLabel channelsLabel;
        private static javax.swing.JLabel channelsValue;
        private javax.swing.JButton connectButton;
        private javax.swing.JFrame connectFrame;
        private javax.swing.JLabel databaseLabel;
        private javax.swing.JTextField databaseTextField;
        private javax.swing.JComboBox driverCombo;
        private javax.swing.JLabel driverLabel;
        private static javax.swing.JCheckBox duplicateCheckBox;
        private static javax.swing.JLabel durationLabel;
        private static javax.swing.JLabel durationValue;
        private static javax.swing.JLabel fileFilenameLabel;
        private static javax.swing.JLabel fileIDLabel;
        private static javax.swing.JTextField fileIDValue;
        private javax.swing.JLabel filterLabel;
        private static javax.swing.JTextField filterTextField;
        private static javax.swing.JCheckBox genreCheckBox;
        private static javax.swing.JTextField genreValue;
        private static javax.swing.JLabel groupLabel;
        private static javax.swing.JTextField groupValue;
        private net.exent.locutus.gui.Help help;
        private javax.swing.JLabel hostLabel;
        private javax.swing.JTextField hostTextField;
        private net.exent.locutus.gui.Matching matching;
        private static javax.swing.JPanel metadataPanel;
        private javax.swing.JPanel miscPanel;
        private static javax.swing.JCheckBox modifiedCheckBox;
        private javax.swing.JButton openButton;
        private javax.swing.JLabel passwordLabel;
        private javax.swing.JPasswordField passwordPasswordField;
        private static javax.swing.JCheckBox pinnedCheckBox;
        private static javax.swing.JProgressBar progressBar;
        private static javax.swing.JLabel progressLabel;
        private javax.swing.JButton quitButton;
        private static javax.swing.JCheckBox releasedCheckBox;
        private static javax.swing.JTextField releasedValue;
        private static javax.swing.JLabel samplerateLabel;
        private static javax.swing.JLabel samplerateValue;
        private static javax.swing.JButton setMetadataButton;
        private net.exent.locutus.gui.Settings settings;
        private javax.swing.JTabbedPane tabPane;
        private static javax.swing.JCheckBox titleCheckBox;
        private static javax.swing.JTextField titleValue;
        private javax.swing.JPanel topPanel;
        private static javax.swing.JLabel trackIDLabel;
        private static javax.swing.JTextField trackIDValue;
        private static javax.swing.JCheckBox trackMBIDCheckBox;
        private static javax.swing.JTextField trackMBIDValue;
        private javax.swing.JPanel trackPanel;
        private static javax.swing.JCheckBox tracknumberCheckBox;
        private static javax.swing.JTextField tracknumberValue;
        private net.exent.locutus.gui.Uncompared uncompared;
        private javax.swing.JButton updateButton;
        private javax.swing.JLabel usernameLabel;
        private javax.swing.JTextField usernameTextField;
        // End of variables declaration//GEN-END:variables
}
