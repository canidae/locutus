/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * Settings.java
 *
 * Created on Oct 10, 2009, 9:17:05 PM
 */
package net.exent.locutus.gui;

import java.sql.ResultSet;
import java.sql.SQLException;
import javax.swing.table.DefaultTableModel;
import net.exent.locutus.database.Database;

/**
 *
 * @author canidae
 */
public class Settings extends javax.swing.JPanel {

	/** Creates new form Settings */
	public Settings() {
		initComponents();
	}

	public void updateSettings() {
		DefaultTableModel table = (DefaultTableModel) otherSettingsTable.getModel();
		table.setRowCount(0);
		try {
			ResultSet rs = Database.getSettingList();
			if (rs == null)
				return;

			while (rs.next()) {
				String key = rs.getString("key");
				String valueString = rs.getString("value");
				int valueInt;
				try {
					valueInt = Integer.parseInt(valueString);
				} catch (NumberFormatException e) {
					valueInt = 0;
				}
				double valueDouble;
				try {
					valueDouble = Double.parseDouble(valueString);
				} catch (NumberFormatException e) {
					valueDouble = 0.0;
				}
				boolean valueBoolean = valueBoolean = Boolean.parseBoolean(valueString);
				String description = "<html>" + rs.getString("description").replace(". ", ".<br />") + "</html>";
				if ("album_weight".equals(key)) {
					weightAlbumSlider.setValue(valueInt);
					weightAlbumSlider.setToolTipText(description);
				} else if ("allow_group_duplicates".equals(key)) {
					optionAllowGroupDuplicatesCheckBox.setSelected(valueBoolean);
					optionAllowGroupDuplicatesCheckBox.setToolTipText(description);
				} else if ("artist_weight".equals(key)) {
					weightArtistSlider.setValue(valueInt);
					weightArtistSlider.setToolTipText(description);
				} else if ("audioscrobbler_artist_tag_url".equals(key)) {
					audioscrobblerArtistURLTextField.setText(valueString);
					audioscrobblerArtistURLTextField.setToolTipText(description);
				} else if ("audioscrobbler_query_interval".equals(key)) {
					daemonAudioscrobblerQueryIntervalSlider.setValue(valueInt);
					daemonAudioscrobblerQueryIntervalSlider.setToolTipText(description);
				} else if ("audioscrobbler_track_tag_url".equals(key)) {
					audioscrobblerTrackURLTextField.setText(valueString);
					audioscrobblerTrackURLTextField.setToolTipText(description);
				} else if ("cache_lifetime".equals(key)) {
					daemonCacheLifetimeSlider.setValue(valueInt);
					daemonCacheLifetimeSlider.setToolTipText(description);
				} else if ("combine_groups".equals(key)) {
					optionCombineGroupsCheckBox.setSelected(valueBoolean);
					optionCombineGroupsCheckBox.setToolTipText(description);
				} else if ("combine_threshold".equals(key)) {
					compareCombineThresholdSlider.setValue((int) (valueDouble * 100));
					compareCombineThresholdSlider.setToolTipText(description);
				} else if ("compare_relative_score".equals(key)) {
					compareCompareRelativeScoreSlider.setValue((int) (valueDouble * 100));
					compareCompareRelativeScoreSlider.setToolTipText(description);
				} else if ("dry_run".equals(key)) {
					optionDryRunCheckBox.setSelected(valueBoolean);
					optionDryRunCheckBox.setToolTipText(description);
				} else if ("duplicate_directory".equals(key)) {
					duplicateDirectoryTextField.setText(valueString);
					duplicateDirectoryTextField.setToolTipText(description);
				} else if ("duration_limit".equals(key)) {
					compareDurationLimitSlider.setValue(valueInt);
					compareDurationLimitSlider.setToolTipText(description);
				} else if ("duration_must_match".equals(key)) {
					optionDurationMustMatchCheckBox.setSelected(valueBoolean);
					optionDurationMustMatchCheckBox.setToolTipText(description);
				} else if ("duration_weight".equals(key)) {
					weightDurationSlider.setValue(valueInt);
					weightDurationSlider.setToolTipText(description);
				} else if ("filename_format".equals(key)) {
					filenameFormatTextField.setText(valueString);
					filenameFormatTextField.setToolTipText(description);
				} else if ("filename_illegal_characters".equals(key)) {
					filenameIllegalCharactersTextField.setText(valueString);
					filenameIllegalCharactersTextField.setToolTipText(description);
				} else if ("input_directory".equals(key)) {
					inputDirectoryTextField.setText(valueString);
					inputDirectoryTextField.setToolTipText(description);
				} else if ("lookup_genre".equals(key)) {
					optionLookupGenreCheckBox.setSelected(valueBoolean);
					optionLookupGenreCheckBox.setToolTipText(description);
				} else if ("lookup_mbid".equals(key)) {
					optionLookupMBIDCheckBox.setSelected(valueBoolean);
					optionLookupMBIDCheckBox.setToolTipText(description);
				} else if ("match_min_score".equals(key)) {
					compareMatchMinScoreSlider.setValue((int) (valueDouble * 100));
					compareMatchMinScoreSlider.setToolTipText(description);
				} else if ("max_diff_best_score".equals(key)) {
					compareMaxDiffBestScoreSlider.setValue((int) (valueDouble * 100));
					compareMaxDiffBestScoreSlider.setToolTipText(description);
				} else if ("max_group_size".equals(key)) {
					daemonMaxGroupSizeSlider.setValue(valueInt);
					daemonMaxGroupSizeSlider.setToolTipText(description);
				} else if ("musicbrainz_query_interval".equals(key)) {
					daemonMusicBrainzQueryIntervalSlider.setValue(valueInt);
					daemonMusicBrainzQueryIntervalSlider.setToolTipText(description);
				} else if ("musicbrainz_release_url".equals(key)) {
					musicBrainzReleaseURLTextField.setText(valueString);
					musicBrainzReleaseURLTextField.setToolTipText(description);
				} else if ("musicbrainz_search_url".equals(key)) {
					musicBrainzSearchURLTextField.setText(valueString);
					musicBrainzSearchURLTextField.setToolTipText(description);
				} else if ("only_save_complete_albums".equals(key)) {
					optionOnlySaveCompleteAlbumsCheckBox.setSelected(valueBoolean);
					optionOnlySaveCompleteAlbumsCheckBox.setToolTipText(description);
				} else if ("only_save_if_all_match".equals(key)) {
					optionOnlySaveIfAllMatchCheckBox.setSelected(valueBoolean);
					optionOnlySaveIfAllMatchCheckBox.setToolTipText(description);
				} else if ("output_directory".equals(key)) {
					outputDirectoryTextField.setText(valueString);
					outputDirectoryTextField.setToolTipText(description);
				} else if ("run_interval".equals(key)) {
					daemonRunIntervalSlider.setValue(valueInt);
					daemonRunIntervalSlider.setToolTipText(description);
				} else if ("title_weight".equals(key)) {
					weightTitleSlider.setValue(valueInt);
					weightTitleSlider.setToolTipText(description);
				} else if ("tracknumber_weight".equals(key)) {
					weightTracknumberSlider.setValue(valueInt);
					weightTracknumberSlider.setToolTipText(description);
				} else {
					table.addRow(new Object[]{rs.getString("key"), rs.getString("value")});
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
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

                weightPanel = new javax.swing.JPanel();
                weightArtistLabel = new javax.swing.JLabel();
                weightArtistSlider = new javax.swing.JSlider();
                weightArtistValue = new javax.swing.JLabel();
                weightAlbumLabel = new javax.swing.JLabel();
                weightAlbumSlider = new javax.swing.JSlider();
                weightAlbumValue = new javax.swing.JLabel();
                weightTracknumberLabel = new javax.swing.JLabel();
                weightTracknumberSlider = new javax.swing.JSlider();
                weightTracknumberValue = new javax.swing.JLabel();
                weightTitleLabel = new javax.swing.JLabel();
                weightTitleSlider = new javax.swing.JSlider();
                weightTitleValue = new javax.swing.JLabel();
                weightDurationLabel = new javax.swing.JLabel();
                weightDurationSlider = new javax.swing.JSlider();
                weightDurationValue = new javax.swing.JLabel();
                comparePanel = new javax.swing.JPanel();
                compareCombineThresholdLabel = new javax.swing.JLabel();
                compareCombineThresholdSlider = new javax.swing.JSlider();
                compareCombineThresholdValue = new javax.swing.JLabel();
                compareMaxDiffBestScoreLabel = new javax.swing.JLabel();
                compareMaxDiffBestScoreSlider = new javax.swing.JSlider();
                compareMaxDiffBestScoreValue = new javax.swing.JLabel();
                compareMatchMinScoreLabel = new javax.swing.JLabel();
                compareMatchMinScoreSlider = new javax.swing.JSlider();
                compareMatchMinScoreValue = new javax.swing.JLabel();
                compareCompareRelativeScoreLabel = new javax.swing.JLabel();
                compareCompareRelativeScoreSlider = new javax.swing.JSlider();
                compareCompareRelativeScoreValue = new javax.swing.JLabel();
                compareDurationLimitLabel = new javax.swing.JLabel();
                compareDurationLimitSlider = new javax.swing.JSlider();
                compareDurationLimitValue = new javax.swing.JLabel();
                daemonPanel = new javax.swing.JPanel();
                daemonMaxGroupSizeLabel = new javax.swing.JLabel();
                daemonMaxGroupSizeSlider = new javax.swing.JSlider();
                daemonMaxGroupSizeValue = new javax.swing.JLabel();
                daemonCacheLifetimeLabel = new javax.swing.JLabel();
                daemonCacheLifetimeSlider = new javax.swing.JSlider();
                daemonCacheLifetimeValue = new javax.swing.JLabel();
                daemonRunIntervalLabel = new javax.swing.JLabel();
                daemonRunIntervalSlider = new javax.swing.JSlider();
                daemonRunIntervalValue = new javax.swing.JLabel();
                daemonMusicBrainzQueryIntervalLabel = new javax.swing.JLabel();
                daemonMusicBrainzQueryIntervalSlider = new javax.swing.JSlider();
                daemonMusicBrainzQueryIntervalValue = new javax.swing.JLabel();
                daemonAudioscrobblerQueryIntervalLabel = new javax.swing.JLabel();
                daemonAudioscrobblerQueryIntervalSlider = new javax.swing.JSlider();
                daemonAudioscrobblerQueryIntervalValue = new javax.swing.JLabel();
                optionPanel = new javax.swing.JPanel();
                optionDryRunCheckBox = new javax.swing.JCheckBox();
                optionDurationMustMatchCheckBox = new javax.swing.JCheckBox();
                optionCombineGroupsCheckBox = new javax.swing.JCheckBox();
                optionAllowGroupDuplicatesCheckBox = new javax.swing.JCheckBox();
                optionOnlySaveCompleteAlbumsCheckBox = new javax.swing.JCheckBox();
                optionOnlySaveIfAllMatchCheckBox = new javax.swing.JCheckBox();
                optionLookupMBIDCheckBox = new javax.swing.JCheckBox();
                optionLookupGenreCheckBox = new javax.swing.JCheckBox();
                locationPanel = new javax.swing.JPanel();
                inputDirectoryLabel = new javax.swing.JLabel();
                inputDirectoryTextField = new javax.swing.JTextField();
                musicBrainzSearchURLLabel = new javax.swing.JLabel();
                musicBrainzSearchURLTextField = new javax.swing.JTextField();
                musicBrainzReleaseURLLabel = new javax.swing.JLabel();
                musicBrainzReleaseURLTextField = new javax.swing.JTextField();
                audioscrobblerArtistURLLabel = new javax.swing.JLabel();
                audioscrobblerArtistURLTextField = new javax.swing.JTextField();
                audioscrobblerTrackURLLabel = new javax.swing.JLabel();
                audioscrobblerTrackURLTextField = new javax.swing.JTextField();
                outputDirectoryLabel = new javax.swing.JLabel();
                outputDirectoryTextField = new javax.swing.JTextField();
                duplicateDirectoryLabel = new javax.swing.JLabel();
                duplicateDirectoryTextField = new javax.swing.JTextField();
                filenameFormatLabel = new javax.swing.JLabel();
                filenameFormatTextField = new javax.swing.JTextField();
                filenameIllegalCharactersLabel = new javax.swing.JLabel();
                filenameIllegalCharactersTextField = new javax.swing.JTextField();
                otherSettingsPanel = new javax.swing.JPanel();
                otherSettingsScrollPane = new javax.swing.JScrollPane();
                otherSettingsTable = new javax.swing.JTable();
                buttonPanel = new javax.swing.JPanel();
                saveSettingsButton = new javax.swing.JButton();
                resetWeightButton = new javax.swing.JButton();
                resetCompareButton = new javax.swing.JButton();
                resetDaemonButton = new javax.swing.JButton();
                resetOptionsButton = new javax.swing.JButton();
                resetLocationsButton = new javax.swing.JButton();
                resetOtherSettingsButton = new javax.swing.JButton();
                resetAllButton = new javax.swing.JButton();
                buttonSeparator = new javax.swing.JSeparator();
                resetLabel = new javax.swing.JLabel();

                addComponentListener(new java.awt.event.ComponentAdapter() {
                        public void componentHidden(java.awt.event.ComponentEvent evt) {
                                formComponentHidden(evt);
                        }
                        public void componentShown(java.awt.event.ComponentEvent evt) {
                                formComponentShown(evt);
                        }
                });
                setLayout(new java.awt.GridBagLayout());

                weightPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Weight"));
                weightPanel.setLayout(new java.awt.GridBagLayout());

                weightArtistLabel.setText("Artist:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightArtistLabel, gridBagConstraints);

                weightArtistSlider.setMajorTickSpacing(1);
                weightArtistSlider.setMaximum(500);
                weightArtistSlider.setMinimum(1);
                weightArtistSlider.setSnapToTicks(true);
                weightArtistSlider.setValue(100);
                weightArtistSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                weightArtistSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                weightArtistSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                weightArtistSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                weightArtistSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightArtistSlider, gridBagConstraints);

                weightArtistValue.setText("100");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightArtistValue, gridBagConstraints);

                weightAlbumLabel.setText("Album:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightAlbumLabel, gridBagConstraints);

                weightAlbumSlider.setMajorTickSpacing(1);
                weightAlbumSlider.setMaximum(500);
                weightAlbumSlider.setMinimum(1);
                weightAlbumSlider.setSnapToTicks(true);
                weightAlbumSlider.setValue(100);
                weightAlbumSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                weightAlbumSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                weightAlbumSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                weightAlbumSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                weightAlbumSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightAlbumSlider, gridBagConstraints);

                weightAlbumValue.setText("100");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightAlbumValue, gridBagConstraints);

                weightTracknumberLabel.setText("Tracknumber:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightTracknumberLabel, gridBagConstraints);

                weightTracknumberSlider.setMajorTickSpacing(1);
                weightTracknumberSlider.setMaximum(500);
                weightTracknumberSlider.setMinimum(1);
                weightTracknumberSlider.setSnapToTicks(true);
                weightTracknumberSlider.setValue(100);
                weightTracknumberSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                weightTracknumberSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                weightTracknumberSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                weightTracknumberSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                weightTracknumberSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightTracknumberSlider, gridBagConstraints);

                weightTracknumberValue.setText("100");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightTracknumberValue, gridBagConstraints);

                weightTitleLabel.setText("Title:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightTitleLabel, gridBagConstraints);

                weightTitleSlider.setMajorTickSpacing(1);
                weightTitleSlider.setMaximum(500);
                weightTitleSlider.setMinimum(1);
                weightTitleSlider.setSnapToTicks(true);
                weightTitleSlider.setValue(100);
                weightTitleSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                weightTitleSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                weightTitleSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                weightTitleSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                weightTitleSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightTitleSlider, gridBagConstraints);

                weightTitleValue.setText("100");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightTitleValue, gridBagConstraints);

                weightDurationLabel.setText("Duration:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightDurationLabel, gridBagConstraints);

                weightDurationSlider.setMajorTickSpacing(1);
                weightDurationSlider.setMaximum(500);
                weightDurationSlider.setMinimum(1);
                weightDurationSlider.setSnapToTicks(true);
                weightDurationSlider.setValue(100);
                weightDurationSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                weightDurationSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                weightDurationSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                weightDurationSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                weightDurationSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightDurationSlider, gridBagConstraints);

                weightDurationValue.setText("100");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                weightPanel.add(weightDurationValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.weightx = 1.0;
                add(weightPanel, gridBagConstraints);

                comparePanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Compare"));
                comparePanel.setLayout(new java.awt.GridBagLayout());

                compareCombineThresholdLabel.setText("Combine threshold:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareCombineThresholdLabel, gridBagConstraints);

                compareCombineThresholdSlider.setMajorTickSpacing(1);
                compareCombineThresholdSlider.setSnapToTicks(true);
                compareCombineThresholdSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                compareCombineThresholdSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                compareCombineThresholdSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                compareCombineThresholdSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                compareCombineThresholdSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareCombineThresholdSlider, gridBagConstraints);

                compareCombineThresholdValue.setText("50");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareCombineThresholdValue, gridBagConstraints);

                compareMaxDiffBestScoreLabel.setText("Max diff best score:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareMaxDiffBestScoreLabel, gridBagConstraints);

                compareMaxDiffBestScoreSlider.setMajorTickSpacing(1);
                compareMaxDiffBestScoreSlider.setSnapToTicks(true);
                compareMaxDiffBestScoreSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                compareMaxDiffBestScoreSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                compareMaxDiffBestScoreSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                compareMaxDiffBestScoreSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                compareMaxDiffBestScoreSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareMaxDiffBestScoreSlider, gridBagConstraints);

                compareMaxDiffBestScoreValue.setText("50");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareMaxDiffBestScoreValue, gridBagConstraints);

                compareMatchMinScoreLabel.setText("Match min score:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareMatchMinScoreLabel, gridBagConstraints);

                compareMatchMinScoreSlider.setMajorTickSpacing(1);
                compareMatchMinScoreSlider.setSnapToTicks(true);
                compareMatchMinScoreSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                compareMatchMinScoreSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                compareMatchMinScoreSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                compareMatchMinScoreSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                compareMatchMinScoreSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareMatchMinScoreSlider, gridBagConstraints);

                compareMatchMinScoreValue.setText("50");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareMatchMinScoreValue, gridBagConstraints);

                compareCompareRelativeScoreLabel.setText("Compare relative score:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareCompareRelativeScoreLabel, gridBagConstraints);

                compareCompareRelativeScoreSlider.setMajorTickSpacing(1);
                compareCompareRelativeScoreSlider.setSnapToTicks(true);
                compareCompareRelativeScoreSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                compareCompareRelativeScoreSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                compareCompareRelativeScoreSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                compareCompareRelativeScoreSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                compareCompareRelativeScoreSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareCompareRelativeScoreSlider, gridBagConstraints);

                compareCompareRelativeScoreValue.setText("50");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareCompareRelativeScoreValue, gridBagConstraints);

                compareDurationLimitLabel.setText("Duration limit:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareDurationLimitLabel, gridBagConstraints);

                compareDurationLimitSlider.setMajorTickSpacing(100);
                compareDurationLimitSlider.setMaximum(60000);
                compareDurationLimitSlider.setSnapToTicks(true);
                compareDurationLimitSlider.setValue(15000);
                compareDurationLimitSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                compareDurationLimitSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                compareDurationLimitSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                compareDurationLimitSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                compareDurationLimitSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareDurationLimitSlider, gridBagConstraints);

                compareDurationLimitValue.setText("15000");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                comparePanel.add(compareDurationLimitValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                add(comparePanel, gridBagConstraints);

                daemonPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Daemon"));
                daemonPanel.setLayout(new java.awt.GridBagLayout());

                daemonMaxGroupSizeLabel.setText("Max group size:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonMaxGroupSizeLabel, gridBagConstraints);

                daemonMaxGroupSizeSlider.setMajorTickSpacing(1);
                daemonMaxGroupSizeSlider.setMaximum(2000);
                daemonMaxGroupSizeSlider.setMinimum(1);
                daemonMaxGroupSizeSlider.setSnapToTicks(true);
                daemonMaxGroupSizeSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                daemonMaxGroupSizeSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                daemonMaxGroupSizeSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                daemonMaxGroupSizeSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                daemonMaxGroupSizeSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonMaxGroupSizeSlider, gridBagConstraints);

                daemonMaxGroupSizeValue.setText("50");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonMaxGroupSizeValue, gridBagConstraints);

                daemonCacheLifetimeLabel.setText("Cache lifetime:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonCacheLifetimeLabel, gridBagConstraints);

                daemonCacheLifetimeSlider.setMajorTickSpacing(1);
                daemonCacheLifetimeSlider.setMaximum(12);
                daemonCacheLifetimeSlider.setMinimum(1);
                daemonCacheLifetimeSlider.setSnapToTicks(true);
                daemonCacheLifetimeSlider.setValue(3);
                daemonCacheLifetimeSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                daemonCacheLifetimeSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                daemonCacheLifetimeSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                daemonCacheLifetimeSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                daemonCacheLifetimeSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonCacheLifetimeSlider, gridBagConstraints);

                daemonCacheLifetimeValue.setText("3");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonCacheLifetimeValue, gridBagConstraints);

                daemonRunIntervalLabel.setText("Run interval:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonRunIntervalLabel, gridBagConstraints);

                daemonRunIntervalSlider.setMajorTickSpacing(1);
                daemonRunIntervalSlider.setMaximum(90);
                daemonRunIntervalSlider.setMinimum(1);
                daemonRunIntervalSlider.setSnapToTicks(true);
                daemonRunIntervalSlider.setValue(7);
                daemonRunIntervalSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                daemonRunIntervalSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                daemonRunIntervalSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                daemonRunIntervalSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                daemonRunIntervalSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonRunIntervalSlider, gridBagConstraints);

                daemonRunIntervalValue.setText("7");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonRunIntervalValue, gridBagConstraints);

                daemonMusicBrainzQueryIntervalLabel.setText("MusicBrainz query interval:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonMusicBrainzQueryIntervalLabel, gridBagConstraints);

                daemonMusicBrainzQueryIntervalSlider.setMajorTickSpacing(1);
                daemonMusicBrainzQueryIntervalSlider.setMaximum(60);
                daemonMusicBrainzQueryIntervalSlider.setMinimum(1);
                daemonMusicBrainzQueryIntervalSlider.setSnapToTicks(true);
                daemonMusicBrainzQueryIntervalSlider.setValue(3);
                daemonMusicBrainzQueryIntervalSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                daemonMusicBrainzQueryIntervalSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                daemonMusicBrainzQueryIntervalSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                daemonMusicBrainzQueryIntervalSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                daemonMusicBrainzQueryIntervalSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonMusicBrainzQueryIntervalSlider, gridBagConstraints);

                daemonMusicBrainzQueryIntervalValue.setText("3");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonMusicBrainzQueryIntervalValue, gridBagConstraints);

                daemonAudioscrobblerQueryIntervalLabel.setText("Audioscrobbler query interval:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonAudioscrobblerQueryIntervalLabel, gridBagConstraints);

                daemonAudioscrobblerQueryIntervalSlider.setMajorTickSpacing(1);
                daemonAudioscrobblerQueryIntervalSlider.setMaximum(60);
                daemonAudioscrobblerQueryIntervalSlider.setMinimum(1);
                daemonAudioscrobblerQueryIntervalSlider.setSnapToTicks(true);
                daemonAudioscrobblerQueryIntervalSlider.setValue(3);
                daemonAudioscrobblerQueryIntervalSlider.setMaximumSize(new java.awt.Dimension(32767, 17));
                daemonAudioscrobblerQueryIntervalSlider.setMinimumSize(new java.awt.Dimension(200, 17));
                daemonAudioscrobblerQueryIntervalSlider.setPreferredSize(new java.awt.Dimension(200, 17));
                daemonAudioscrobblerQueryIntervalSlider.addChangeListener(new javax.swing.event.ChangeListener() {
                        public void stateChanged(javax.swing.event.ChangeEvent evt) {
                                daemonAudioscrobblerQueryIntervalSliderStateChanged(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonAudioscrobblerQueryIntervalSlider, gridBagConstraints);

                daemonAudioscrobblerQueryIntervalValue.setText("3");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                daemonPanel.add(daemonAudioscrobblerQueryIntervalValue, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.weightx = 1.0;
                add(daemonPanel, gridBagConstraints);

                optionPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Options"));
                optionPanel.setLayout(new java.awt.GridBagLayout());

                optionDryRunCheckBox.setText("Dry run");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionDryRunCheckBox, gridBagConstraints);

                optionDurationMustMatchCheckBox.setText("Duration must match");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionDurationMustMatchCheckBox, gridBagConstraints);

                optionCombineGroupsCheckBox.setText("Combine groups");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionCombineGroupsCheckBox, gridBagConstraints);

                optionAllowGroupDuplicatesCheckBox.setText("Allow duplicate files in group");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionAllowGroupDuplicatesCheckBox, gridBagConstraints);

                optionOnlySaveCompleteAlbumsCheckBox.setText("Only save complete albums");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionOnlySaveCompleteAlbumsCheckBox, gridBagConstraints);

                optionOnlySaveIfAllMatchCheckBox.setText("Only save if all files in group match");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 5;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionOnlySaveIfAllMatchCheckBox, gridBagConstraints);

                optionLookupMBIDCheckBox.setText("Lookup MBID");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 6;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionLookupMBIDCheckBox, gridBagConstraints);

                optionLookupGenreCheckBox.setText("Lookup genre");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 7;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                optionPanel.add(optionLookupGenreCheckBox, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.weightx = 1.0;
                add(optionPanel, gridBagConstraints);

                locationPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Locations & formatting"));
                locationPanel.setLayout(new java.awt.GridBagLayout());

                inputDirectoryLabel.setText("Input directory:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(inputDirectoryLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(inputDirectoryTextField, gridBagConstraints);

                musicBrainzSearchURLLabel.setText("MusicBrainz search URL:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 7;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(musicBrainzSearchURLLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 7;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(musicBrainzSearchURLTextField, gridBagConstraints);

                musicBrainzReleaseURLLabel.setText("MusicBrainz release URL:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 8;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(musicBrainzReleaseURLLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 8;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(musicBrainzReleaseURLTextField, gridBagConstraints);

                audioscrobblerArtistURLLabel.setText("Audioscrobbler artist URL:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 6;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(audioscrobblerArtistURLLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 6;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(audioscrobblerArtistURLTextField, gridBagConstraints);

                audioscrobblerTrackURLLabel.setText("Audioscrobbler track URL:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 5;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(audioscrobblerTrackURLLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 5;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(audioscrobblerTrackURLTextField, gridBagConstraints);

                outputDirectoryLabel.setText("Output directory:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(outputDirectoryLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(outputDirectoryTextField, gridBagConstraints);

                duplicateDirectoryLabel.setText("Duplicate directory:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(duplicateDirectoryLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(duplicateDirectoryTextField, gridBagConstraints);

                filenameFormatLabel.setText("Filename format:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(filenameFormatLabel, gridBagConstraints);

                filenameFormatTextField.setMaximumSize(new java.awt.Dimension(2147483647, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(filenameFormatTextField, gridBagConstraints);

                filenameIllegalCharactersLabel.setText("Illegal characters:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(filenameIllegalCharactersLabel, gridBagConstraints);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 4;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                locationPanel.add(filenameIllegalCharactersTextField, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.gridwidth = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.weightx = 1.0;
                add(locationPanel, gridBagConstraints);

                otherSettingsPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Other settings"));
                otherSettingsPanel.setLayout(new javax.swing.BoxLayout(otherSettingsPanel, javax.swing.BoxLayout.LINE_AXIS));

                otherSettingsTable.setModel(new javax.swing.table.DefaultTableModel(
                        new Object [][] {

                        },
                        new String [] {
                                "Key", "Value"
                        }
                ) {
                        Class[] types = new Class [] {
                                java.lang.String.class, java.lang.Object.class
                        };

                        public Class getColumnClass(int columnIndex) {
                                return types [columnIndex];
                        }
                });
                otherSettingsScrollPane.setViewportView(otherSettingsTable);

                otherSettingsPanel.add(otherSettingsScrollPane);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                add(otherSettingsPanel, gridBagConstraints);

                buttonPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Save & reset settings"));
                buttonPanel.setLayout(new java.awt.GridBagLayout());

                saveSettingsButton.setMnemonic('S');
                saveSettingsButton.setText("Save");
                saveSettingsButton.setToolTipText("Save local changes to the database");
                saveSettingsButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                saveSettingsButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(saveSettingsButton, gridBagConstraints);

                resetWeightButton.setText("Weight");
                resetWeightButton.setToolTipText("Reset the default values for weighting in the database");
                resetWeightButton.setFocusable(false);
                resetWeightButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                resetWeightButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 4;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(resetWeightButton, gridBagConstraints);

                resetCompareButton.setText("Compare");
                resetCompareButton.setToolTipText("Reset the default values for comparing in the database");
                resetCompareButton.setFocusable(false);
                resetCompareButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                resetCompareButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 5;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(resetCompareButton, gridBagConstraints);

                resetDaemonButton.setText("Daemon");
                resetDaemonButton.setToolTipText("Reset the default values for the daemon in the database");
                resetDaemonButton.setFocusable(false);
                resetDaemonButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                resetDaemonButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 6;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(resetDaemonButton, gridBagConstraints);

                resetOptionsButton.setText("Options");
                resetOptionsButton.setToolTipText("Reset the default values for options in the database");
                resetOptionsButton.setFocusable(false);
                resetOptionsButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                resetOptionsButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 7;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(resetOptionsButton, gridBagConstraints);

                resetLocationsButton.setText("Locations & formatting");
                resetLocationsButton.setToolTipText("Reset the default values for locations & formatting in the database");
                resetLocationsButton.setFocusable(false);
                resetLocationsButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                resetLocationsButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 8;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(resetLocationsButton, gridBagConstraints);

                resetOtherSettingsButton.setText("Other settings");
                resetOtherSettingsButton.setToolTipText("Reset the default values for other settings in the database");
                resetOtherSettingsButton.setFocusable(false);
                resetOtherSettingsButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                resetOtherSettingsButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 9;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(resetOtherSettingsButton, gridBagConstraints);

                resetAllButton.setText("All");
                resetAllButton.setToolTipText("Reset all settings to default values in the database");
                resetAllButton.setFocusable(false);
                resetAllButton.addActionListener(new java.awt.event.ActionListener() {
                        public void actionPerformed(java.awt.event.ActionEvent evt) {
                                resetAllButtonActionPerformed(evt);
                        }
                });
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 10;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                buttonPanel.add(resetAllButton, gridBagConstraints);

                buttonSeparator.setOrientation(javax.swing.SwingConstants.VERTICAL);
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.VERTICAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.EAST;
                gridBagConstraints.weightx = 1.0;
                buttonPanel.add(buttonSeparator, gridBagConstraints);

                resetLabel.setText("Reset:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.insets = new java.awt.Insets(4, 4, 4, 4);
                buttonPanel.add(resetLabel, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 3;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.SOUTH;
                gridBagConstraints.weightx = 1.0;
                add(buttonPanel, gridBagConstraints);
        }// </editor-fold>//GEN-END:initComponents

    private void formComponentShown(java.awt.event.ComponentEvent evt) {//GEN-FIRST:event_formComponentShown
	    Locutus.hideMetadata();
	    updateSettings();
    }//GEN-LAST:event_formComponentShown

    private void formComponentHidden(java.awt.event.ComponentEvent evt) {//GEN-FIRST:event_formComponentHidden
	    Locutus.showMetadata();
    }//GEN-LAST:event_formComponentHidden

    private void weightDurationSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_weightDurationSliderStateChanged
	    weightDurationValue.setText("" + weightDurationSlider.getValue());
    }//GEN-LAST:event_weightDurationSliderStateChanged

    private void weightTitleSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_weightTitleSliderStateChanged
	    weightTitleValue.setText("" + weightTitleSlider.getValue());
    }//GEN-LAST:event_weightTitleSliderStateChanged

    private void weightTracknumberSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_weightTracknumberSliderStateChanged
	    weightTracknumberValue.setText("" + weightTracknumberSlider.getValue());
    }//GEN-LAST:event_weightTracknumberSliderStateChanged

    private void weightAlbumSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_weightAlbumSliderStateChanged
	    weightAlbumValue.setText("" + weightAlbumSlider.getValue());
    }//GEN-LAST:event_weightAlbumSliderStateChanged

    private void weightArtistSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_weightArtistSliderStateChanged
	    weightArtistValue.setText("" + weightArtistSlider.getValue());
    }//GEN-LAST:event_weightArtistSliderStateChanged

    private void compareDurationLimitSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_compareDurationLimitSliderStateChanged
	    compareDurationLimitValue.setText("" + compareDurationLimitSlider.getValue());
    }//GEN-LAST:event_compareDurationLimitSliderStateChanged

    private void compareCompareRelativeScoreSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_compareCompareRelativeScoreSliderStateChanged
	    compareCompareRelativeScoreValue.setText("" + compareCompareRelativeScoreSlider.getValue());
    }//GEN-LAST:event_compareCompareRelativeScoreSliderStateChanged

    private void compareMatchMinScoreSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_compareMatchMinScoreSliderStateChanged
	    compareMatchMinScoreValue.setText("" + compareMatchMinScoreSlider.getValue());
    }//GEN-LAST:event_compareMatchMinScoreSliderStateChanged

    private void compareMaxDiffBestScoreSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_compareMaxDiffBestScoreSliderStateChanged
	    compareMaxDiffBestScoreValue.setText("" + compareMaxDiffBestScoreSlider.getValue());
    }//GEN-LAST:event_compareMaxDiffBestScoreSliderStateChanged

    private void compareCombineThresholdSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_compareCombineThresholdSliderStateChanged
	    compareCombineThresholdValue.setText("" + compareCombineThresholdSlider.getValue());
    }//GEN-LAST:event_compareCombineThresholdSliderStateChanged

    private void daemonAudioscrobblerQueryIntervalSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_daemonAudioscrobblerQueryIntervalSliderStateChanged
	    daemonAudioscrobblerQueryIntervalValue.setText("" + daemonAudioscrobblerQueryIntervalSlider.getValue());
    }//GEN-LAST:event_daemonAudioscrobblerQueryIntervalSliderStateChanged

    private void daemonMusicBrainzQueryIntervalSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_daemonMusicBrainzQueryIntervalSliderStateChanged
	    daemonMusicBrainzQueryIntervalValue.setText("" + daemonMusicBrainzQueryIntervalSlider.getValue());
    }//GEN-LAST:event_daemonMusicBrainzQueryIntervalSliderStateChanged

    private void daemonRunIntervalSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_daemonRunIntervalSliderStateChanged
	    daemonRunIntervalValue.setText("" + daemonRunIntervalSlider.getValue());
    }//GEN-LAST:event_daemonRunIntervalSliderStateChanged

    private void daemonCacheLifetimeSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_daemonCacheLifetimeSliderStateChanged
	    daemonCacheLifetimeValue.setText("" + daemonCacheLifetimeSlider.getValue());
    }//GEN-LAST:event_daemonCacheLifetimeSliderStateChanged

    private void daemonMaxGroupSizeSliderStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_daemonMaxGroupSizeSliderStateChanged
	    daemonMaxGroupSizeValue.setText("" + daemonMaxGroupSizeSlider.getValue());
    }//GEN-LAST:event_daemonMaxGroupSizeSliderStateChanged

    private void resetAllButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetAllButtonActionPerformed
	    try {
		    Database.resetAllSettings();
	    } catch (SQLException e) {
		    e.printStackTrace();
	    }
	    updateSettings();
    }//GEN-LAST:event_resetAllButtonActionPerformed

    private void resetOtherSettingsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetOtherSettingsButtonActionPerformed
	    DefaultTableModel table = (DefaultTableModel) otherSettingsTable.getModel();
	    for (int r = 0; r < table.getRowCount(); ++r) {
		    String key = (String) table.getValueAt(r, 0);
		    try {
			    if (key != null && !key.equals(""))
				    Database.resetSetting(key);
		    } catch (SQLException e) {
			    e.printStackTrace();
		    }
	    }
	    updateSettings();
    }//GEN-LAST:event_resetOtherSettingsButtonActionPerformed

    private void resetWeightButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetWeightButtonActionPerformed
	    try {
		    Database.resetSetting("album_weight");
		    Database.resetSetting("artist_weight");
		    Database.resetSetting("duration_weight");
		    Database.resetSetting("title_weight");
		    Database.resetSetting("tracknumber_weight");
		    updateSettings();
	    } catch (SQLException e) {
		    e.printStackTrace();
	    }
    }//GEN-LAST:event_resetWeightButtonActionPerformed

    private void resetCompareButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetCompareButtonActionPerformed
	    try {
		    Database.resetSetting("combine_threshold");
		    Database.resetSetting("max_diff_best_score");
		    Database.resetSetting("match_min_score");
		    Database.resetSetting("compare_relative_score");
		    Database.resetSetting("duration_limit");
		    updateSettings();
	    } catch (SQLException e) {
		    e.printStackTrace();
	    }
    }//GEN-LAST:event_resetCompareButtonActionPerformed

    private void resetDaemonButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetDaemonButtonActionPerformed
	    try {
		    Database.resetSetting("max_group_size");
		    Database.resetSetting("cache_lifetime");
		    Database.resetSetting("run_interval");
		    Database.resetSetting("musicbrainz_query_interval");
		    Database.resetSetting("audioscrobbler_query_interval");
		    updateSettings();
	    } catch (SQLException e) {
		    e.printStackTrace();
	    }
    }//GEN-LAST:event_resetDaemonButtonActionPerformed

    private void resetOptionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetOptionsButtonActionPerformed
	    try {
		    Database.resetSetting("dry_run");
		    Database.resetSetting("duration_must_match");
		    Database.resetSetting("combine_groups");
		    Database.resetSetting("allow_group_duplicates");
		    Database.resetSetting("only_save_complete_albums");
		    Database.resetSetting("only_save_if_all_match");
		    Database.resetSetting("lookup_mbid");
		    Database.resetSetting("lookup_genre");
		    updateSettings();
	    } catch (SQLException e) {
		    e.printStackTrace();
	    }
    }//GEN-LAST:event_resetOptionsButtonActionPerformed

    private void resetLocationsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetLocationsButtonActionPerformed
	    try {
		    Database.resetSetting("input_directory");
		    Database.resetSetting("output_directory");
		    Database.resetSetting("duplicate_directory");
		    Database.resetSetting("filename_format");
		    Database.resetSetting("filename_illegal_characters");
		    Database.resetSetting("audioscrobbler_track_tag_url");
		    Database.resetSetting("audioscrobbler_artist_tag_url");
		    Database.resetSetting("musicbrainz_search_url");
		    Database.resetSetting("musicbrainz_release_url");
		    updateSettings();
	    } catch (SQLException e) {
		    e.printStackTrace();
	    }
    }//GEN-LAST:event_resetLocationsButtonActionPerformed

    private void saveSettingsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_saveSettingsButtonActionPerformed
	    try {
		    Database.setSetting("cache_lifetime", "" + daemonCacheLifetimeSlider.getValue());
		    Database.setSetting("album_weight", "" + weightAlbumSlider.getValue());
		    Database.setSetting("allow_group_duplicates", "" + optionAllowGroupDuplicatesCheckBox.isSelected());
		    Database.setSetting("artist_weight", "" + weightArtistSlider.getValue());
		    Database.setSetting("audioscrobbler_artist_tag_url", audioscrobblerArtistURLTextField.getText());
		    Database.setSetting("audioscrobbler_query_interval", "" + daemonAudioscrobblerQueryIntervalSlider.getValue());
		    Database.setSetting("audioscrobbler_track_tag_url", audioscrobblerTrackURLTextField.getText());
		    Database.setSetting("combine_groups", "" + optionCombineGroupsCheckBox.isSelected());
		    Database.setSetting("combine_threshold", "" + ((double) compareCombineThresholdSlider.getValue() / 100.0));
		    Database.setSetting("compare_relative_score", "" + ((double) compareCompareRelativeScoreSlider.getValue() / 100.0));
		    Database.setSetting("dry_run", "" + optionDryRunCheckBox.isSelected());
		    Database.setSetting("duplicate_directory", duplicateDirectoryTextField.getText());
		    Database.setSetting("duration_limit", "" + compareDurationLimitSlider.getValue());
		    Database.setSetting("duration_must_match", "" + optionDurationMustMatchCheckBox.isSelected());
		    Database.setSetting("duration_weight", "" + weightDurationSlider.getValue());
		    Database.setSetting("filename_format", filenameFormatTextField.getText());
		    Database.setSetting("filename_illegal_characters", filenameIllegalCharactersTextField.getText());
		    Database.setSetting("input_directory", inputDirectoryTextField.getText());
		    Database.setSetting("lookup_genre", "" + optionLookupGenreCheckBox.isSelected());
		    Database.setSetting("match_min_score", "" + ((double) compareMatchMinScoreSlider.getValue() / 100.0));
		    Database.setSetting("max_diff_best_score", "" + ((double) compareMaxDiffBestScoreSlider.getValue() / 100.0));
		    Database.setSetting("max_group_size", "" + daemonMaxGroupSizeSlider.getValue());
		    Database.setSetting("lookup_mbid", "" + optionLookupMBIDCheckBox.isSelected());
		    Database.setSetting("musicbrainz_search_url", musicBrainzSearchURLTextField.getText());
		    Database.setSetting("musicbrainz_query_interval", "" + daemonMusicBrainzQueryIntervalSlider.getValue());
		    Database.setSetting("only_save_complete_albums", "" + optionOnlySaveCompleteAlbumsCheckBox.isSelected());
		    Database.setSetting("only_save_if_all_match", "" + optionOnlySaveIfAllMatchCheckBox.isSelected());
		    Database.setSetting("output_directory", outputDirectoryTextField.getText());
		    Database.setSetting("musicbrainz_release_url", musicBrainzReleaseURLTextField.getText());
		    Database.setSetting("run_interval", "" + daemonRunIntervalSlider.getValue());
		    Database.setSetting("title_weight", "" + weightTitleSlider.getValue());
		    Database.setSetting("tracknumber_weight", "" + weightTracknumberSlider.getValue());

		    DefaultTableModel table = (DefaultTableModel) otherSettingsTable.getModel();
		    for (int r = 0; r < table.getRowCount(); ++r) {
			    String key = (String) table.getValueAt(r, 0);
			    String value = (String) table.getValueAt(r, 1);
			    if (value == null)
				    value = "";
			    try {
				    if (key != null && !key.equals(""))
					    Database.setSetting(key, value);
			    } catch (SQLException e) {
				    e.printStackTrace();
			    }
		    }
		    updateSettings();
	    } catch (SQLException e) {
		    e.printStackTrace();
	    }
    }//GEN-LAST:event_saveSettingsButtonActionPerformed
        // Variables declaration - do not modify//GEN-BEGIN:variables
        private javax.swing.JLabel audioscrobblerArtistURLLabel;
        private javax.swing.JTextField audioscrobblerArtistURLTextField;
        private javax.swing.JLabel audioscrobblerTrackURLLabel;
        private javax.swing.JTextField audioscrobblerTrackURLTextField;
        private javax.swing.JPanel buttonPanel;
        private javax.swing.JSeparator buttonSeparator;
        private javax.swing.JLabel compareCombineThresholdLabel;
        private javax.swing.JSlider compareCombineThresholdSlider;
        private javax.swing.JLabel compareCombineThresholdValue;
        private javax.swing.JLabel compareCompareRelativeScoreLabel;
        private javax.swing.JSlider compareCompareRelativeScoreSlider;
        private javax.swing.JLabel compareCompareRelativeScoreValue;
        private javax.swing.JLabel compareDurationLimitLabel;
        private javax.swing.JSlider compareDurationLimitSlider;
        private javax.swing.JLabel compareDurationLimitValue;
        private javax.swing.JLabel compareMatchMinScoreLabel;
        private javax.swing.JSlider compareMatchMinScoreSlider;
        private javax.swing.JLabel compareMatchMinScoreValue;
        private javax.swing.JLabel compareMaxDiffBestScoreLabel;
        private javax.swing.JSlider compareMaxDiffBestScoreSlider;
        private javax.swing.JLabel compareMaxDiffBestScoreValue;
        private javax.swing.JPanel comparePanel;
        private javax.swing.JLabel daemonAudioscrobblerQueryIntervalLabel;
        private javax.swing.JSlider daemonAudioscrobblerQueryIntervalSlider;
        private javax.swing.JLabel daemonAudioscrobblerQueryIntervalValue;
        private javax.swing.JLabel daemonCacheLifetimeLabel;
        private javax.swing.JSlider daemonCacheLifetimeSlider;
        private javax.swing.JLabel daemonCacheLifetimeValue;
        private javax.swing.JLabel daemonMaxGroupSizeLabel;
        private javax.swing.JSlider daemonMaxGroupSizeSlider;
        private javax.swing.JLabel daemonMaxGroupSizeValue;
        private javax.swing.JLabel daemonMusicBrainzQueryIntervalLabel;
        private javax.swing.JSlider daemonMusicBrainzQueryIntervalSlider;
        private javax.swing.JLabel daemonMusicBrainzQueryIntervalValue;
        private javax.swing.JPanel daemonPanel;
        private javax.swing.JLabel daemonRunIntervalLabel;
        private javax.swing.JSlider daemonRunIntervalSlider;
        private javax.swing.JLabel daemonRunIntervalValue;
        private javax.swing.JLabel duplicateDirectoryLabel;
        private javax.swing.JTextField duplicateDirectoryTextField;
        private javax.swing.JLabel filenameFormatLabel;
        private javax.swing.JTextField filenameFormatTextField;
        private javax.swing.JLabel filenameIllegalCharactersLabel;
        private javax.swing.JTextField filenameIllegalCharactersTextField;
        private javax.swing.JLabel inputDirectoryLabel;
        private javax.swing.JTextField inputDirectoryTextField;
        private javax.swing.JPanel locationPanel;
        private javax.swing.JLabel musicBrainzReleaseURLLabel;
        private javax.swing.JTextField musicBrainzReleaseURLTextField;
        private javax.swing.JLabel musicBrainzSearchURLLabel;
        private javax.swing.JTextField musicBrainzSearchURLTextField;
        private javax.swing.JCheckBox optionAllowGroupDuplicatesCheckBox;
        private javax.swing.JCheckBox optionCombineGroupsCheckBox;
        private javax.swing.JCheckBox optionDryRunCheckBox;
        private javax.swing.JCheckBox optionDurationMustMatchCheckBox;
        private javax.swing.JCheckBox optionLookupGenreCheckBox;
        private javax.swing.JCheckBox optionLookupMBIDCheckBox;
        private javax.swing.JCheckBox optionOnlySaveCompleteAlbumsCheckBox;
        private javax.swing.JCheckBox optionOnlySaveIfAllMatchCheckBox;
        private javax.swing.JPanel optionPanel;
        private javax.swing.JPanel otherSettingsPanel;
        private javax.swing.JScrollPane otherSettingsScrollPane;
        private javax.swing.JTable otherSettingsTable;
        private javax.swing.JLabel outputDirectoryLabel;
        private javax.swing.JTextField outputDirectoryTextField;
        private javax.swing.JButton resetAllButton;
        private javax.swing.JButton resetCompareButton;
        private javax.swing.JButton resetDaemonButton;
        private javax.swing.JLabel resetLabel;
        private javax.swing.JButton resetLocationsButton;
        private javax.swing.JButton resetOptionsButton;
        private javax.swing.JButton resetOtherSettingsButton;
        private javax.swing.JButton resetWeightButton;
        private javax.swing.JButton saveSettingsButton;
        private javax.swing.JLabel weightAlbumLabel;
        private javax.swing.JSlider weightAlbumSlider;
        private javax.swing.JLabel weightAlbumValue;
        private javax.swing.JLabel weightArtistLabel;
        private javax.swing.JSlider weightArtistSlider;
        private javax.swing.JLabel weightArtistValue;
        private javax.swing.JLabel weightDurationLabel;
        private javax.swing.JSlider weightDurationSlider;
        private javax.swing.JLabel weightDurationValue;
        private javax.swing.JPanel weightPanel;
        private javax.swing.JLabel weightTitleLabel;
        private javax.swing.JSlider weightTitleSlider;
        private javax.swing.JLabel weightTitleValue;
        private javax.swing.JLabel weightTracknumberLabel;
        private javax.swing.JSlider weightTracknumberSlider;
        private javax.swing.JLabel weightTracknumberValue;
        // End of variables declaration//GEN-END:variables
}
