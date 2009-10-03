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
import java.util.LinkedList;
import java.util.List;
import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.JTree;
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
			return title + " (" + tracks + "/" + tracks_compared + "/" + mbids_matched + " tracks/compared/mbids, " + files_compared + " files)";
		}
	}

	private class TrackNode {

		private int track_id;
		private String title;
		private String artist;
		private String album;
		private String album_artist;
		private int tracknumber;
		private int duration;
		private double score;
		private boolean got_mbid_match;
		private boolean got_files;

		public TrackNode(ResultSet rs) throws SQLException {
			track_id = rs.getInt("track_id");
			title = rs.getString("title");
			artist = rs.getString("track_artist");
			album = rs.getString("album");
			album_artist = rs.getString("artist");
			tracknumber = rs.getInt("tracknumber");
			duration = rs.getInt("duration");
			score = rs.getDouble("score");
			got_mbid_match = rs.getBoolean("mbid_match");
			got_files = (rs.getInt("file_id") > 0 && !rs.wasNull());
		}

		@Override
		public String toString() {
			return (tracknumber > 9 ? tracknumber : "0" + tracknumber) + " - " + duration + " - " + album_artist + " - " + album + " - " + artist + " - " + title;
		}
	}

	private class FileNode {

		private int file_id;
		private String filename;
		private int duration;
		private String album;
		private String album_artist;
		private String artist;
		private String title;
		private int tracknumber;
		private double score;
		private boolean mbid_match;
		private int track_id;

		public FileNode(ResultSet rs) throws SQLException {
			file_id = rs.getInt("file_id");
			filename = rs.getString("filename");
			duration = rs.getInt("file_duration");
			album = rs.getString("file_album");
			album_artist = rs.getString("file_albumartist");
			artist = rs.getString("file_artist");
			title = rs.getString("file_title");
			try {
				tracknumber = Integer.parseInt(rs.getString("file_tracknumber"));
			} catch (NumberFormatException e) {
				tracknumber = 0;
			}
			score = rs.getDouble("score");
			mbid_match = rs.getBoolean("mbid_match");
			track_id = rs.getInt("file_track_id");
		}

		@Override
		public String toString() {
			return (tracknumber > 9 ? tracknumber : "0" + tracknumber) + " - " + duration + " - " + album_artist + " - " + album + " - " + artist + " - " + title + " (" + filename + ")";
		}
	}

	private class MatchingCellRenderer implements TreeCellRenderer {

		public Component getTreeCellRendererComponent(JTree tree, Object value, boolean selected, boolean expanded, boolean leaf, int row, boolean hasFocus) {
			String icon = "unknown_icon.png";
			Object node = ((DefaultMutableTreeNode) value).getUserObject();
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
				if (track.got_mbid_match)
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
				if (file.track_id > 0)
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
			}
			JLabel label = new JLabel(value.toString(), new ImageIcon(getClass().getResource("/net/exent/locutus/gui/icons/" + icon)), JLabel.LEFT);
			if (selected)
				label.setForeground(Color.BLUE);
			return label;
		}
	}

	public void updateTree() {
		try {
			ResultSet rs = Database.getMatching(Locutus.getFilter());

			if (rs == null)
				return;

			jTree1.removeAll();
			DefaultTreeModel tree = (DefaultTreeModel) jTree1.getModel();
			DefaultMutableTreeNode root = (DefaultMutableTreeNode) tree.getRoot();
			while (rs.next()) {
				DefaultMutableTreeNode child = new DefaultMutableTreeNode(new AlbumNode(rs));
				child.add(new DefaultMutableTreeNode("hai!"));
				root.add(child);
			}
			tree.setRoot(root);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	/** Creates new form Matching */
	public Matching() {
		initComponents();
		jTree1.setCellRenderer(new MatchingCellRenderer());
	}

	/** This method is called from within the constructor to
	 * initialize the form.
	 * WARNING: Do NOT modify this code. The content of this method is
	 * always regenerated by the Form Editor.
	 */
	@SuppressWarnings("unchecked")
        // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
        private void initComponents() {

                jScrollPane2 = new javax.swing.JScrollPane();
                jTree1 = new javax.swing.JTree();

                addComponentListener(new java.awt.event.ComponentAdapter() {
                        public void componentShown(java.awt.event.ComponentEvent evt) {
                                formComponentShown(evt);
                        }
                });

                javax.swing.tree.DefaultMutableTreeNode treeNode1 = new javax.swing.tree.DefaultMutableTreeNode("root");
                jTree1.setModel(new javax.swing.tree.DefaultTreeModel(treeNode1));
                jTree1.setRootVisible(false);
                jTree1.addTreeWillExpandListener(new javax.swing.event.TreeWillExpandListener() {
                        public void treeWillCollapse(javax.swing.event.TreeExpansionEvent evt)throws javax.swing.tree.ExpandVetoException {
                        }
                        public void treeWillExpand(javax.swing.event.TreeExpansionEvent evt)throws javax.swing.tree.ExpandVetoException {
                                jTree1TreeWillExpand(evt);
                        }
                });
                jTree1.addKeyListener(new java.awt.event.KeyAdapter() {
                        public void keyPressed(java.awt.event.KeyEvent evt) {
                                jTree1KeyPressed(evt);
                        }
                });
                jScrollPane2.setViewportView(jTree1);

                javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
                this.setLayout(layout);
                layout.setHorizontalGroup(
                        layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(jScrollPane2, javax.swing.GroupLayout.DEFAULT_SIZE, 630, Short.MAX_VALUE)
                );
                layout.setVerticalGroup(
                        layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(jScrollPane2, javax.swing.GroupLayout.DEFAULT_SIZE, 562, Short.MAX_VALUE)
                );
        }// </editor-fold>//GEN-END:initComponents

	private void formComponentShown(java.awt.event.ComponentEvent evt) {//GEN-FIRST:event_formComponentShown
		updateTree();
	}//GEN-LAST:event_formComponentShown

	private void jTree1TreeWillExpand(javax.swing.event.TreeExpansionEvent evt)throws javax.swing.tree.ExpandVetoException {//GEN-FIRST:event_jTree1TreeWillExpand
		DefaultMutableTreeNode node = (DefaultMutableTreeNode) evt.getPath().getLastPathComponent();
		if (node.getUserObject() instanceof AlbumNode) {
			AlbumNode album = (AlbumNode) node.getUserObject();
			node.removeAllChildren();
			try {
				ResultSet rs = Database.getAlbum(album.album_id);
				int last_tracknum = -1;
				DefaultMutableTreeNode track = null;
				while (rs.next()) {
					int tracknum = rs.getInt("tracknumber");
					if (tracknum != last_tracknum) {
						track = new DefaultMutableTreeNode(new TrackNode(rs));
						last_tracknum = tracknum;
						node.add(track);
					}
					if ((rs.getInt("file_id") > 0) && !rs.wasNull()) {
						DefaultMutableTreeNode file = new DefaultMutableTreeNode(new FileNode(rs));
						track.add(file);
					}
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			/* recursively expand all child nodes of this album */
			List<TreePath> expand = new LinkedList<TreePath>();
			
			/*
			 *     public void expandAll(JTree tree, boolean expand) {
			TreeNode root = (TreeNode)tree.getModel().getRoot();

			// Traverse tree from root
			expandAll(tree, new TreePath(root), expand);
			}
			private void expandAll(JTree tree, TreePath parent, boolean expand) {
			// Traverse children
			TreeNode node = (TreeNode)parent.getLastPathComponent();
			if (node.getChildCount() >= 0) {
			for (Enumeration e=node.children(); e.hasMoreElements(); ) {
			TreeNode n = (TreeNode)e.nextElement();
			TreePath path = parent.pathByAddingChild(n);
			expandAll(tree, path, expand);
			}
			}

			// Expansion or collapse must be done bottom-up
			if (expand) {
			tree.expandPath(parent);
			} else {
			tree.collapsePath(parent);
			}
			}
			 */
		}
	}//GEN-LAST:event_jTree1TreeWillExpand

	private void jTree1KeyPressed(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_jTree1KeyPressed
		switch (evt.getKeyCode()) {
			case KeyEvent.VK_DELETE:
				/* album selected:
				 *  - delete all comparisons in album
				 * track selected:
				 *  - delete all comparisons for track
				 * file selected:
				 *  - delete comparison for file
				 */
				break;

			case KeyEvent.VK_SPACE:
				/* album selected:
				 *  - mark all files in album as correct
				 * track selected:
				 *  - mark all files compared to track as correct
				 * file selected:
				 *  - mark file as correct
				 */
				break;

			case KeyEvent.VK_ESCAPE:
				/* album selected:
				 *  - undo all changes in album
				 * track selected:
				 *  - undo all changes for track
				 * file selected:
				 *  - undo change for file
				 */
				break;

			case KeyEvent.VK_ENTER:
				/* album selected:
				 *  - commit changes in album
				 * track selected:
				 *  - commit changes for track
				 * file selected:
				 *  - commit changes for file
				 */
				break;

			default:
				break;
		}
	}//GEN-LAST:event_jTree1KeyPressed
        // Variables declaration - do not modify//GEN-BEGIN:variables
        private javax.swing.JScrollPane jScrollPane2;
        private javax.swing.JTree jTree1;
        // End of variables declaration//GEN-END:variables
}
