/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * Matching.java
 *
 * Created on Aug 28, 2009, 7:46:24 PM
 */
package net.exent.locutus.gui;

import java.awt.Color;
import java.awt.Component;
import java.awt.event.KeyEvent;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.JTree;
import javax.swing.border.TitledBorder;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeCellRenderer;
import javax.swing.tree.TreePath;
import net.exent.locutus.database.Database;

/**
 *
 * @author canidae
 */
public class Matching extends javax.swing.JPanel {

	private class AlbumNode {

		private int album_id;
		private String title;
		private int tracks;
		private int files_compared;
		private int tracks_compared;
		private int mbids_matched;
		private double max_score;
		private double avg_score;
		private double min_score;

		public AlbumNode(ResultSet rs) throws SQLException {
			album_id = rs.getInt("album_id");
			title = rs.getString("album");
			tracks = rs.getInt("tracks");
			files_compared = rs.getInt("files_compared");
			tracks_compared = rs.getInt("tracks_compared");
			mbids_matched = rs.getInt("mbids_matched");
			max_score = rs.getDouble("max_score");
			avg_score = rs.getDouble("avg_score");
			min_score = rs.getDouble("min_score");
		}

		@Override
		public String toString() {
			/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
			 * solution? add \u200b which is a zero width character (ie. invisible) */
			return "\u200b" + title + " (" + tracks + "/" + tracks_compared + "/" + mbids_matched + " tracks/compared/mbids, " + files_compared + " files not matched)";
		}
	}

	private class TrackNode {

		private int track_id;
		private String title;
		private int tracknumber;
		private int duration;
		private String artist;
		private String album;
		private String album_artist;
		private double score;
		private boolean got_match;
		private boolean got_files;

		public TrackNode(ResultSet rs) throws SQLException {
			track_id = rs.getInt("track_track_id");
			title = rs.getString("track_title");
			tracknumber = rs.getInt("track_tracknumber");
			duration = rs.getInt("track_duration");
			artist = rs.getString("trackartist_name");
			album = rs.getString("album_title");
			album_artist = rs.getString("albumartist_name");
			score = rs.getDouble("comparison_score");
			got_match = (rs.getInt("file_track_id") > 0 && !rs.wasNull());
			got_files = (rs.getInt("file_file_id") > 0 && !rs.wasNull());
		}

		@Override
		public String toString() {
			/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
			 * solution? add \u200b which is a zero width character (ie. invisible) */
			return "\u200b" + (tracknumber > 9 ? tracknumber : "0" + tracknumber) + " - " + duration + " - " + album_artist + " - " + album + " - " + artist + " - " + title;
		}
	}

	private class FileNode {

		private static final int NONE = 0;
		private static final int SAVE = 1;
		private static final int DELETE = 2;
		private int file_id;
		private String filename;
		private String album;
		private String album_artist;
		private String artist;
		private String title;
		private int tracknumber;
		private int duration;
		private int file_track_id;
		private int compare_track_id;
		private double score;
		private boolean mbid_match;
		private int status;

		public FileNode(ResultSet rs) throws SQLException {
			file_id = rs.getInt("file_file_id");
			filename = rs.getString("file_filename");
			album = rs.getString("file_album");
			album_artist = rs.getString("file_albumartist");
			artist = rs.getString("file_artist");
			title = rs.getString("file_title");
			try {
				tracknumber = Integer.parseInt(rs.getString("file_tracknumber"));
			} catch (NumberFormatException e) {
				tracknumber = 0;
			}
			duration = rs.getInt("file_duration");
			file_track_id = rs.getInt("file_track_id");
			compare_track_id = rs.getInt("track_track_id");
			score = rs.getDouble("comparison_score");
			mbid_match = rs.getBoolean("comparison_mbid_match");
			status = NONE;
		}

		@Override
		public String toString() {
			/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
			 * solution? add \u200b which is a zero width character (ie. invisible) */
			return "\u200b" + (tracknumber > 9 ? tracknumber : "0" + tracknumber) + " - " + duration + " - " + album_artist + " - " + album + " - " + artist + " - " + title + " (" + filename + ")";
		}
	}

	private class MatchingCellRenderer implements TreeCellRenderer {

		public Component getTreeCellRendererComponent(JTree tree, Object value, boolean selected, boolean expanded, boolean leaf, int row, boolean hasFocus) {
			String icon = "unknown_icon.png";
			Object node = ((DefaultMutableTreeNode) value).getUserObject();
			int status = FileNode.NONE;
			if (node instanceof AlbumNode) {
				AlbumNode album = (AlbumNode) node;
				if (album.min_score < 0.4)
					icon = "album_25.png";
				else if (album.min_score < 0.55)
					icon = "album_40.png";
				else if (album.min_score < 0.7)
					icon = "album_55.png";
				else if (album.min_score < 0.85)
					icon = "album_70.png";
				else
					icon = "album_85.png";
			} else if (node instanceof TrackNode) {
				TrackNode track = (TrackNode) node;
				if (track.got_match)
					icon = "track_matched.png";
				else if (!track.got_files)
					icon = "track_none.png";
				else if (track.score < 0.4)
					icon = "track_25.png";
				else if (track.score < 0.55)
					icon = "track_40.png";
				else if (track.score < 0.7)
					icon = "track_55.png";
				else if (track.score < 0.85)
					icon = "track_70.png";
				else
					icon = "track_85.png";
			} else if (node instanceof FileNode) {
				FileNode file = (FileNode) node;
				if (file.file_track_id > 0)
					icon = "file_matched.png";
				else if (file.score < 0.4)
					icon = "file_25.png";
				else if (file.score < 0.55)
					icon = "file_40.png";
				else if (file.score < 0.7)
					icon = "file_55.png";
				else if (file.score < 0.85)
					icon = "file_70.png";
				else
					icon = "file_85.png";
				status = file.status;

				if (selected)
					showFileMetadata(file);
			}
			JLabel label = new JLabel(value.toString(), new ImageIcon(getClass().getResource("/net/exent/locutus/gui/icons/" + icon)), JLabel.LEFT);
			label.setOpaque(true);
			if (selected) {
				label.setBackground(new Color(200, 200, 255));
				if (!(node instanceof FileNode))
					hideFileMetadata();
			} else {
				label.setBackground(new Color(255, 255, 255));
			}
			if (status == FileNode.SAVE)
				label.setForeground(new Color(0, 150, 0));
			else if (status == FileNode.DELETE)
				label.setForeground(new Color(150, 0, 0));
			return label;
		}
	}

	public void updateTree() {
		try {
			ResultSet rs = Database.getMatchingList(Locutus.getFilter());

			if (rs == null)
				return;

			DefaultTreeModel model = (DefaultTreeModel) matchingTree.getModel();
			DefaultMutableTreeNode root = (DefaultMutableTreeNode) model.getRoot();
			List<DefaultMutableTreeNode> remove = new ArrayList<DefaultMutableTreeNode>();
			Enumeration albums = root.children();
			while (albums.hasMoreElements())
				remove.add((DefaultMutableTreeNode) albums.nextElement());
			for (DefaultMutableTreeNode r : remove)
				model.removeNodeFromParent(r);
			while (rs.next()) {
				DefaultMutableTreeNode album = new DefaultMutableTreeNode(new AlbumNode(rs));
				model.insertNodeInto(new DefaultMutableTreeNode("\u200bPlaceholder"), album, 0);
				model.insertNodeInto(album, root, model.getChildCount(root));
			}
			model.setRoot(root);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	private void showFileMetadata(FileNode file) {
		filenameLabel.setText("File: " + file.filename);
	}

	private void hideFileMetadata() {
		filenameLabel.setText("File:");
	}

	private void updateAlbum(DefaultMutableTreeNode albumnode) {
		if (albumnode == null || !(albumnode.getUserObject() instanceof AlbumNode))
			return;
		DefaultTreeModel model = (DefaultTreeModel) matchingTree.getModel();
		if (albumnode.getChildCount() > 0) {
			List<DefaultMutableTreeNode> remove = new ArrayList<DefaultMutableTreeNode>();
			Enumeration tracks = albumnode.children();
			while (tracks.hasMoreElements())
				remove.add((DefaultMutableTreeNode) tracks.nextElement());
			for (DefaultMutableTreeNode r : remove)
				model.removeNodeFromParent(r);
		}
		AlbumNode album = (AlbumNode) albumnode.getUserObject();
		try {
			ResultSet rs = Database.getMatchingDetails(album.album_id);
			int last_tracknum = -1;
			DefaultMutableTreeNode track = null;
			while (rs.next()) {
				int tracknum = rs.getInt("track_tracknumber");
				if (tracknum != last_tracknum) {
					track = new DefaultMutableTreeNode(new TrackNode(rs));
					last_tracknum = tracknum;
					model.insertNodeInto(track, albumnode, model.getChildCount(albumnode));
				}
				if ((rs.getInt("file_file_id") > 0) && !rs.wasNull()) {
					DefaultMutableTreeNode file = new DefaultMutableTreeNode(new FileNode(rs));
					model.insertNodeInto(file, track, model.getChildCount(track));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	private void saveAlbum(DefaultMutableTreeNode albumnode) {
		/* TODO: proper updating of album data (possibly difficult) */
		AlbumNode album = (AlbumNode) albumnode.getUserObject();
		if (album != null && !album.title.endsWith((" <needs update>")))
			album.title += " <needs update>";
		Enumeration tracks = albumnode.children();
		while (tracks.hasMoreElements()) {
			Enumeration files = ((DefaultMutableTreeNode) tracks.nextElement()).children();
			while (files.hasMoreElements()) {
				FileNode file = (FileNode) ((DefaultMutableTreeNode) files.nextElement()).getUserObject();
				try {
					if (file.status == FileNode.SAVE)
						Database.matchFile(file.file_id, file.compare_track_id);
					else if (file.status == FileNode.DELETE)
						Database.deleteComparison(file.file_id, file.compare_track_id);
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
	}

	/** Creates new form Matching */
	public Matching() {
		initComponents();
		matchingTree.setCellRenderer(new MatchingCellRenderer());
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

                matchingScrollPane = new javax.swing.JScrollPane();
                matchingTree = new javax.swing.JTree();
                metadataPanel = new javax.swing.JPanel();
                filenameLabel = new javax.swing.JLabel();
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

                addComponentListener(new java.awt.event.ComponentAdapter() {
                        public void componentShown(java.awt.event.ComponentEvent evt) {
                                formComponentShown(evt);
                        }
                });
                setLayout(new java.awt.BorderLayout());

                javax.swing.tree.DefaultMutableTreeNode treeNode1 = new javax.swing.tree.DefaultMutableTreeNode("root");
                matchingTree.setModel(new javax.swing.tree.DefaultTreeModel(treeNode1));
                matchingTree.setRootVisible(false);
                matchingTree.addTreeWillExpandListener(new javax.swing.event.TreeWillExpandListener() {
                        public void treeWillCollapse(javax.swing.event.TreeExpansionEvent evt)throws javax.swing.tree.ExpandVetoException {
                        }
                        public void treeWillExpand(javax.swing.event.TreeExpansionEvent evt)throws javax.swing.tree.ExpandVetoException {
                                matchingTreeTreeWillExpand(evt);
                        }
                });
                matchingTree.addTreeExpansionListener(new javax.swing.event.TreeExpansionListener() {
                        public void treeCollapsed(javax.swing.event.TreeExpansionEvent evt) {
                        }
                        public void treeExpanded(javax.swing.event.TreeExpansionEvent evt) {
                                matchingTreeTreeExpanded(evt);
                        }
                });
                matchingTree.addKeyListener(new java.awt.event.KeyAdapter() {
                        public void keyPressed(java.awt.event.KeyEvent evt) {
                                matchingTreeKeyPressed(evt);
                        }
                });
                matchingScrollPane.setViewportView(matchingTree);

                add(matchingScrollPane, java.awt.BorderLayout.CENTER);

                metadataPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Metadata"));
                metadataPanel.setLayout(new java.awt.GridBagLayout());

                filenameLabel.setText("File:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                metadataPanel.add(filenameLabel, gridBagConstraints);

                miscPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Misc"));
                miscPanel.setLayout(new java.awt.GridBagLayout());

                fileTrackIDLabel.setText("Track ID:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 2;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileTrackIDLabel, gridBagConstraints);

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
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.weighty = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                miscPanel.add(fileFileIDLabel, gridBagConstraints);

                fileGroupValue.setEditable(false);
                fileGroupValue.setPreferredSize(new java.awt.Dimension(100, 25));
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
                fileModified.setEnabled(false);
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
                fileDuplicate.setEnabled(false);
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
                fileDurationLabel.setPreferredSize(null);
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
                fileChannelsLabel.setPreferredSize(null);
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
                fileBitrateLabel.setPreferredSize(null);
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
                fileSamplerateLabel.setPreferredSize(null);
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
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                metadataPanel.add(miscPanel, gridBagConstraints);

                artistPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Artist"));
                artistPanel.setLayout(new java.awt.GridBagLayout());

                fileArtistLabel.setText("Name:");
                fileArtistLabel.setMaximumSize(new java.awt.Dimension(88, 17));
                fileArtistLabel.setMinimumSize(new java.awt.Dimension(88, 17));
                fileArtistLabel.setPreferredSize(new java.awt.Dimension(88, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistLabel, gridBagConstraints);

                fileArtistValue.setMinimumSize(new java.awt.Dimension(256, 25));
                fileArtistValue.setPreferredSize(new java.awt.Dimension(256, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistValue, gridBagConstraints);

                fileArtistSortLabel.setText("Sort name:");
                fileArtistSortLabel.setMaximumSize(new java.awt.Dimension(88, 17));
                fileArtistSortLabel.setMinimumSize(new java.awt.Dimension(88, 17));
                fileArtistSortLabel.setPreferredSize(new java.awt.Dimension(88, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistSortLabel, gridBagConstraints);

                fileArtistSortValue.setMinimumSize(new java.awt.Dimension(256, 25));
                fileArtistSortValue.setPreferredSize(new java.awt.Dimension(256, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistSortValue, gridBagConstraints);

                fileArtistMBIDLabel.setText("MBID:");
                fileArtistMBIDLabel.setMaximumSize(new java.awt.Dimension(88, 17));
                fileArtistMBIDLabel.setMinimumSize(new java.awt.Dimension(88, 17));
                fileArtistMBIDLabel.setPreferredSize(new java.awt.Dimension(88, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                artistPanel.add(fileArtistMBIDLabel, gridBagConstraints);

                fileArtistMBIDValue.setMinimumSize(new java.awt.Dimension(256, 25));
                fileArtistMBIDValue.setPreferredSize(new java.awt.Dimension(256, 25));
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
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                metadataPanel.add(artistPanel, gridBagConstraints);

                trackPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Track"));
                trackPanel.setLayout(new java.awt.GridBagLayout());

                fileTrackMBIDValue.setMinimumSize(new java.awt.Dimension(256, 25));
                fileTrackMBIDValue.setPreferredSize(new java.awt.Dimension(256, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.gridwidth = 3;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTrackMBIDValue, gridBagConstraints);

                fileGenreValue.setMinimumSize(new java.awt.Dimension(64, 25));
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
                fileTrackMBIDLabel.setMaximumSize(new java.awt.Dimension(88, 17));
                fileTrackMBIDLabel.setMinimumSize(new java.awt.Dimension(88, 17));
                fileTrackMBIDLabel.setPreferredSize(new java.awt.Dimension(88, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTrackMBIDLabel, gridBagConstraints);

                fileTitleValue.setMinimumSize(new java.awt.Dimension(256, 25));
                fileTitleValue.setPreferredSize(new java.awt.Dimension(256, 25));
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
                fileTitleLabel.setMaximumSize(new java.awt.Dimension(88, 17));
                fileTitleLabel.setMinimumSize(new java.awt.Dimension(88, 17));
                fileTitleLabel.setPreferredSize(new java.awt.Dimension(88, 17));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 0;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTitleLabel, gridBagConstraints);

                fileTracknumberValue.setMaximumSize(new java.awt.Dimension(32, 25));
                fileTracknumberValue.setMinimumSize(new java.awt.Dimension(32, 25));
                fileTracknumberValue.setPreferredSize(new java.awt.Dimension(32, 25));
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTracknumberValue, gridBagConstraints);

                fileTracknumberLabel.setText("Tracknumber:");
                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 0;
                gridBagConstraints.gridy = 1;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
                gridBagConstraints.weightx = 1.0;
                gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
                trackPanel.add(fileTracknumberLabel, gridBagConstraints);

                gridBagConstraints = new java.awt.GridBagConstraints();
                gridBagConstraints.gridx = 1;
                gridBagConstraints.gridy = 2;
                gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                metadataPanel.add(trackPanel, gridBagConstraints);

                albumPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Album"));
                albumPanel.setPreferredSize(new java.awt.Dimension(304, 104));
                albumPanel.setLayout(new java.awt.GridBagLayout());

                fileAlbumValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileAlbumValue.setPreferredSize(new java.awt.Dimension(100, 25));
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

                fileReleasedValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileReleasedValue.setPreferredSize(new java.awt.Dimension(100, 25));
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

                fileAlbumMBIDValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileAlbumMBIDValue.setPreferredSize(new java.awt.Dimension(100, 25));
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
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
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

                fileAlbumArtistValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileAlbumArtistValue.setPreferredSize(new java.awt.Dimension(100, 25));
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

                fileAlbumArtistMBIDValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileAlbumArtistMBIDValue.setPreferredSize(new java.awt.Dimension(100, 25));
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

                fileAlbumArtistSortValue.setMinimumSize(new java.awt.Dimension(64, 25));
                fileAlbumArtistSortValue.setPreferredSize(new java.awt.Dimension(100, 25));
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
                gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTHWEST;
                metadataPanel.add(albumArtistPanel, gridBagConstraints);

                add(metadataPanel, java.awt.BorderLayout.SOUTH);
        }// </editor-fold>//GEN-END:initComponents

	private void formComponentShown(java.awt.event.ComponentEvent evt) {//GEN-FIRST:event_formComponentShown
		updateTree();
	}//GEN-LAST:event_formComponentShown

	private void matchingTreeTreeWillExpand(javax.swing.event.TreeExpansionEvent evt)throws javax.swing.tree.ExpandVetoException {//GEN-FIRST:event_matchingTreeTreeWillExpand
		DefaultMutableTreeNode node = (DefaultMutableTreeNode) evt.getPath().getLastPathComponent();
		updateAlbum(node);
	}//GEN-LAST:event_matchingTreeTreeWillExpand

	private void matchingTreeKeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_matchingTreeKeyPressed
		if (matchingTree.getSelectionCount() <= 0)
			return;
		TreePath[] paths = matchingTree.getSelectionPaths();
		DefaultMutableTreeNode active_album = null;
		List<DefaultMutableTreeNode> filetreenodes = new ArrayList<DefaultMutableTreeNode>();
		DefaultMutableTreeNode selected = null;
		for (TreePath path : paths) {
			selected = (DefaultMutableTreeNode) path.getLastPathComponent();
			Object node = selected.getUserObject();
			if (node instanceof AlbumNode) {
				active_album = selected;
				Enumeration tracks = selected.children();
				while (tracks.hasMoreElements()) {
					Enumeration files = ((DefaultMutableTreeNode) tracks.nextElement()).children();
					while (files.hasMoreElements())
						filetreenodes.add((DefaultMutableTreeNode) files.nextElement());
				}
			} else if (node instanceof TrackNode) {
				active_album = (DefaultMutableTreeNode) selected.getParent();
				Enumeration files = selected.children();
				while (files.hasMoreElements())
					filetreenodes.add((DefaultMutableTreeNode) files.nextElement());
			} else if (node instanceof FileNode) {
				active_album = (DefaultMutableTreeNode) selected.getParent().getParent();
				filetreenodes.add(selected);
			}
		}
		switch (evt.getKeyCode()) {
			case KeyEvent.VK_DELETE:
			case KeyEvent.VK_D:
				for (DefaultMutableTreeNode treenode : filetreenodes)
					((FileNode) treenode.getUserObject()).status = FileNode.DELETE;
				if (matchingTree.getSelectionCount() == 1)
					selected = selected.getNextNode();
				break;

			case KeyEvent.VK_ENTER:
			case KeyEvent.VK_S:
				for (DefaultMutableTreeNode treenode : filetreenodes)
					((FileNode) treenode.getUserObject()).status = FileNode.SAVE;
				if (matchingTree.getSelectionCount() == 1)
					selected = selected.getNextNode();
				break;

			case KeyEvent.VK_ESCAPE:
			case KeyEvent.VK_R:
				for (DefaultMutableTreeNode treenode : filetreenodes)
					((FileNode) treenode.getUserObject()).status = FileNode.NONE;
				if (matchingTree.getSelectionCount() == 1)
					selected = selected.getNextNode();
				break;

			case KeyEvent.VK_A:
				if (matchingTree.getSelectionCount() != 1)
					break;
				if (evt.isShiftDown()) {
					if (selected.getUserObject() instanceof AlbumNode)
						selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) matchingTree.getModel().getRoot()).getChildBefore(active_album);
					else
						selected = active_album;
				} else {
					selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) matchingTree.getModel().getRoot()).getChildAfter(active_album);
				}
				break;

			case KeyEvent.VK_T:
				if (matchingTree.getSelectionCount() != 1)
					break;
				if (selected.getUserObject() instanceof AlbumNode) {
					if (selected.getChildCount() > 0 && !evt.isShiftDown())
						selected = selected.getNextNode();
				} else if (selected.getUserObject() instanceof TrackNode) {
					if (evt.isShiftDown())
						selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildBefore(selected);
					else
						selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildAfter(selected);
				} else if (selected.getUserObject() instanceof FileNode) {
					selected = (DefaultMutableTreeNode) selected.getParent();
					if (!evt.isShiftDown())
						selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildAfter(selected);
				}
				break;

			case KeyEvent.VK_F:
				if (matchingTree.getSelectionCount() != 1)
					break;
				if (selected.getUserObject() instanceof AlbumNode) {
					if (evt.isShiftDown())
						break;
					Enumeration tracks = selected.children();
					while (tracks.hasMoreElements()) {
						Enumeration files = ((DefaultMutableTreeNode) tracks.nextElement()).children();
						if (files.hasMoreElements()) {
							selected = (DefaultMutableTreeNode) files.nextElement();
							break;
						}
					}
				} else if (selected.getUserObject() instanceof TrackNode) {
					if (evt.isShiftDown()) {
						DefaultMutableTreeNode next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildBefore(selected);
						while (next != null) {
							if (next.getChildCount() > 0) {
								selected = (DefaultMutableTreeNode) next.getLastChild();
								break;
							}
							next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) next.getParent()).getChildBefore(next);
						}
					} else {
						if (selected.getChildCount() > 0) {
							selected = selected.getNextNode();
							break;
						}
						DefaultMutableTreeNode next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildAfter(selected);
						while (next != null) {
							if (next.getChildCount() > 0) {
								selected = next.getNextNode();
								break;
							}
							next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) next.getParent()).getChildAfter(next);
						}
					}
				} else if (selected.getUserObject() instanceof FileNode) {
					if (evt.isShiftDown()) {
						DefaultMutableTreeNode next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildBefore(selected);
						if (next != null) {
							selected = next;
							break;
						}
						next = (DefaultMutableTreeNode) selected.getParent();
						next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) next.getParent()).getChildBefore(next);
						while (next != null) {
							if (next.getChildCount() > 0) {
								selected = (DefaultMutableTreeNode) next.getLastChild();
								break;
							}
							next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) next.getParent()).getChildBefore(next);
						}
					} else {
						DefaultMutableTreeNode next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildAfter(selected);
						if (next != null) {
							selected = next;
							break;
						}
						next = (DefaultMutableTreeNode) selected.getParent();
						next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) next.getParent()).getChildAfter(next);
						while (next != null) {
							if (next.getChildCount() > 0) {
								selected = next.getNextNode();
								break;
							}
							next = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) next.getParent()).getChildAfter(next);
						}
					}
				}
				break;

			case KeyEvent.VK_E:
				if (active_album == null)
					break;
				if (selected != null && selected.getUserObject() instanceof AlbumNode)
					updateAlbum(selected);
				matchingTree.expandPath(new TreePath(active_album.getPath()));
				/* expand all child nodes of this album */
				Enumeration tracks = active_album.children();
				while (tracks.hasMoreElements())
					matchingTree.expandPath(new TreePath(((DefaultMutableTreeNode) tracks.nextElement()).getPath()));
				selected = null;
				break;

			case KeyEvent.VK_SPACE:
				if (evt.isControlDown()) {
					/* update all albums and reload tree */
					Enumeration albums = ((DefaultMutableTreeNode) matchingTree.getModel().getRoot()).children();
					while (albums.hasMoreElements())
						saveAlbum((DefaultMutableTreeNode) albums.nextElement());
					updateTree();
				} else {
					/* update files in active album and reload album */
					saveAlbum(active_album);
					updateAlbum(active_album);
					selected = active_album;
					matchingTree.expandPath(new TreePath(active_album.getPath()));
				}
				break;

			default:
				return;
		}
		if (selected != null) {
			TreePath path = new TreePath(selected.getPath());
			if (matchingTree.isCollapsed(path))
				matchingTree.expandPath(path);
			matchingTree.setSelectionPath(path);
			matchingTree.scrollPathToVisible(path);
			Enumeration albums = ((DefaultMutableTreeNode) matchingTree.getModel().getRoot()).children();
			while (albums.hasMoreElements()) {
				DefaultMutableTreeNode album = (DefaultMutableTreeNode) albums.nextElement();
				TreePath albumpath = new TreePath(album.getPath());
				if (matchingTree.isCollapsed(albumpath))
					continue;
				if (!albumpath.isDescendant(path)) {
					matchingTree.collapsePath(albumpath);
				} else {
					Enumeration tracks = album.children();
					while (tracks.hasMoreElements()) {
						DefaultMutableTreeNode track = (DefaultMutableTreeNode) tracks.nextElement();
						TreePath trackpath = new TreePath(track.getPath());
						if (matchingTree.isExpanded(trackpath) && !trackpath.isDescendant(path))
							matchingTree.collapsePath(trackpath);
					}
				}
			}
		}
		matchingTree.repaint();
	}//GEN-LAST:event_matchingTreeKeyPressed

	private void matchingTreeTreeExpanded(javax.swing.event.TreeExpansionEvent evt) {//GEN-FIRST:event_matchingTreeTreeExpanded
//		DefaultMutableTreeNode node = (DefaultMutableTreeNode) evt.getPath().getLastPathComponent();
//		if (node.getUserObject() instanceof AlbumNode) {
//			/* expand all child nodes of this album */
//			Enumeration tracks = node.children();
//			while (tracks.hasMoreElements())
//				jTree1.expandPath(new TreePath(((DefaultMutableTreeNode) tracks.nextElement()).getPath()));
//		}
	}//GEN-LAST:event_matchingTreeTreeExpanded
        // Variables declaration - do not modify//GEN-BEGIN:variables
        private javax.swing.JPanel albumArtistPanel;
        private javax.swing.JPanel albumPanel;
        private javax.swing.JPanel artistPanel;
        private javax.swing.JLabel fileAlbumArtistLabel;
        private javax.swing.JLabel fileAlbumArtistMBIDLabel;
        private javax.swing.JTextField fileAlbumArtistMBIDValue;
        private javax.swing.JLabel fileAlbumArtistSortLabel;
        private javax.swing.JTextField fileAlbumArtistSortValue;
        private javax.swing.JTextField fileAlbumArtistValue;
        private javax.swing.JLabel fileAlbumLabel;
        private javax.swing.JLabel fileAlbumMBIDLabel;
        private javax.swing.JTextField fileAlbumMBIDValue;
        private javax.swing.JTextField fileAlbumValue;
        private javax.swing.JLabel fileArtistLabel;
        private javax.swing.JLabel fileArtistMBIDLabel;
        private javax.swing.JTextField fileArtistMBIDValue;
        private javax.swing.JLabel fileArtistSortLabel;
        private javax.swing.JTextField fileArtistSortValue;
        private javax.swing.JTextField fileArtistValue;
        private javax.swing.JLabel fileBitrateLabel;
        private javax.swing.JLabel fileBitrateValue;
        private javax.swing.JLabel fileChannelsLabel;
        private javax.swing.JLabel fileChannelsValue;
        private javax.swing.JCheckBox fileDuplicate;
        private javax.swing.JLabel fileDurationLabel;
        private javax.swing.JLabel fileDurationValue;
        private javax.swing.JLabel fileFileIDLabel;
        private javax.swing.JTextField fileFileIDValue;
        private javax.swing.JLabel fileGenreLabel;
        private javax.swing.JTextField fileGenreValue;
        private javax.swing.JLabel fileGroupLabel;
        private javax.swing.JTextField fileGroupValue;
        private javax.swing.JCheckBox fileModified;
        private javax.swing.JCheckBox filePinned;
        private javax.swing.JLabel fileReleasedLabel;
        private javax.swing.JTextField fileReleasedValue;
        private javax.swing.JLabel fileSamplerateLabel;
        private javax.swing.JLabel fileSamplerateValue;
        private javax.swing.JButton fileSaveButton;
        private javax.swing.JLabel fileTitleLabel;
        private javax.swing.JTextField fileTitleValue;
        private javax.swing.JLabel fileTrackIDLabel;
        private javax.swing.JTextField fileTrackIDValue;
        private javax.swing.JLabel fileTrackMBIDLabel;
        private javax.swing.JTextField fileTrackMBIDValue;
        private javax.swing.JLabel fileTracknumberLabel;
        private javax.swing.JTextField fileTracknumberValue;
        private javax.swing.JLabel filenameLabel;
        private javax.swing.JScrollPane matchingScrollPane;
        private javax.swing.JTree matchingTree;
        private javax.swing.JPanel metadataPanel;
        private javax.swing.JPanel miscPanel;
        private javax.swing.JPanel trackPanel;
        // End of variables declaration//GEN-END:variables
}
