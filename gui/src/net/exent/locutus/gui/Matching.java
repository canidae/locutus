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
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeCellRenderer;
import javax.swing.tree.TreePath;
import net.exent.locutus.data.Album;
import net.exent.locutus.data.Metafile;
import net.exent.locutus.data.Track;
import net.exent.locutus.database.Database;

/**
 *
 * @author canidae
 */
public class Matching extends javax.swing.JPanel {

	private class MatchingCellRenderer implements TreeCellRenderer {

		public Component getTreeCellRendererComponent(JTree tree, Object value, boolean selected, boolean expanded, boolean leaf, int row, boolean hasFocus) {
			String icon = "unknown_icon.png";
			Object node = ((DefaultMutableTreeNode) value).getUserObject();
			int status = Metafile.NONE;
			if (node instanceof Album) {
				Album album = (Album) node;
				if (album.getMinScore() < 0.4)
					icon = "album_25.png";
				else if (album.getMinScore() < 0.55)
					icon = "album_40.png";
				else if (album.getMinScore() < 0.7)
					icon = "album_55.png";
				else if (album.getMinScore() < 0.85)
					icon = "album_70.png";
				else
					icon = "album_85.png";
			} else if (node instanceof Track) {
				Track track = (Track) node;
				if (track.hasGotMatch())
					icon = "track_matched.png";
				else if (!track.hasGotFiles())
					icon = "track_none.png";
				else if (track.getScore() < 0.4)
					icon = "track_25.png";
				else if (track.getScore() < 0.55)
					icon = "track_40.png";
				else if (track.getScore() < 0.7)
					icon = "track_55.png";
				else if (track.getScore() < 0.85)
					icon = "track_70.png";
				else
					icon = "track_85.png";
			} else if (node instanceof Metafile) {
				Metafile file = (Metafile) node;
				if (file.getTrackID() > 0)
					icon = "file_matched.png";
				else if (file.getScore() < 0.4)
					icon = "file_25.png";
				else if (file.getScore() < 0.55)
					icon = "file_40.png";
				else if (file.getScore() < 0.7)
					icon = "file_55.png";
				else if (file.getScore() < 0.85)
					icon = "file_70.png";
				else
					icon = "file_85.png";
				status = file.getStatus();

				if (selected)
					Locutus.showMetadata(new Metafile[]{file});
			}
			JLabel label = new JLabel(value.toString(), new ImageIcon(getClass().getResource("/net/exent/locutus/gui/icons/" + icon)), JLabel.LEFT);
			label.setOpaque(true);
			if (selected) {
				label.setBackground(new Color(200, 200, 255));
				if (!(node instanceof Metafile))
					Locutus.hideMetadata();
			} else {
				label.setBackground(new Color(255, 255, 255));
			}
			if (status == Metafile.SAVE)
				label.setForeground(new Color(0, 150, 0));
			else if (status == Metafile.DELETE)
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
				DefaultMutableTreeNode album = new DefaultMutableTreeNode(new Album(rs));
				model.insertNodeInto(new DefaultMutableTreeNode("\u200bPlaceholder"), album, 0);
				model.insertNodeInto(album, root, model.getChildCount(root));
			}
			model.setRoot(root);
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	private void updateAlbum(DefaultMutableTreeNode albumnode) {
		if (albumnode == null || !(albumnode.getUserObject() instanceof Album))
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
		Album album = (Album) albumnode.getUserObject();
		try {
			ResultSet rs = Database.getMatchingDetails(album.getAlbumID());
			int last_tracknum = -1;
			DefaultMutableTreeNode track = null;
			while (rs.next()) {
				int tracknum = rs.getInt("track_tracknumber");
				if (tracknum != last_tracknum) {
					track = new DefaultMutableTreeNode(new Track(rs));
					last_tracknum = tracknum;
					model.insertNodeInto(track, albumnode, model.getChildCount(albumnode));
				}
				if ((rs.getInt("file_file_id") > 0) && !rs.wasNull()) {
					DefaultMutableTreeNode file = new DefaultMutableTreeNode(new Metafile(rs));
					model.insertNodeInto(file, track, model.getChildCount(track));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	private void saveAlbum(DefaultMutableTreeNode albumnode) {
		/* TODO: proper updating of album data (possibly difficult) */
		Album album = (Album) albumnode.getUserObject();
		if (album != null && !album.getTitle().endsWith((" <needs update>")))
			album.setTitle(album.getTitle() + " <needs update>");
		Enumeration tracks = albumnode.children();
		while (tracks.hasMoreElements()) {
			Enumeration files = ((DefaultMutableTreeNode) tracks.nextElement()).children();
			while (files.hasMoreElements()) {
				Metafile file = (Metafile) ((DefaultMutableTreeNode) files.nextElement()).getUserObject();
				try {
					if (file.getStatus() == Metafile.SAVE)
						Database.matchFile(file.getFileID(), file.getCompareTrackID());
					else if (file.getStatus() == Metafile.DELETE)
						Database.deleteComparison(file.getFileID(), file.getCompareTrackID());
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
			if (node instanceof Album) {
				active_album = selected;
				Enumeration tracks = selected.children();
				while (tracks.hasMoreElements()) {
					Enumeration files = ((DefaultMutableTreeNode) tracks.nextElement()).children();
					while (files.hasMoreElements())
						filetreenodes.add((DefaultMutableTreeNode) files.nextElement());
				}
			} else if (node instanceof Track) {
				active_album = (DefaultMutableTreeNode) selected.getParent();
				Enumeration files = selected.children();
				while (files.hasMoreElements())
					filetreenodes.add((DefaultMutableTreeNode) files.nextElement());
			} else if (node instanceof Metafile) {
				active_album = (DefaultMutableTreeNode) selected.getParent().getParent();
				filetreenodes.add(selected);
			}
		}
		switch (evt.getKeyCode()) {
			case KeyEvent.VK_DELETE:
			case KeyEvent.VK_D:
				for (DefaultMutableTreeNode treenode : filetreenodes)
					((Metafile) treenode.getUserObject()).setStatus(Metafile.DELETE);
				if (matchingTree.getSelectionCount() == 1)
					selected = selected.getNextNode();
				break;

			case KeyEvent.VK_ENTER:
			case KeyEvent.VK_S:
				for (DefaultMutableTreeNode treenode : filetreenodes)
					((Metafile) treenode.getUserObject()).setStatus(Metafile.SAVE);
				if (matchingTree.getSelectionCount() == 1)
					selected = selected.getNextNode();
				break;

			case KeyEvent.VK_ESCAPE:
			case KeyEvent.VK_R:
				for (DefaultMutableTreeNode treenode : filetreenodes)
					((Metafile) treenode.getUserObject()).setStatus(Metafile.NONE);
				if (matchingTree.getSelectionCount() == 1)
					selected = selected.getNextNode();
				break;

			case KeyEvent.VK_A:
				if (matchingTree.getSelectionCount() != 1)
					break;
				if (evt.isShiftDown()) {
					if (selected.getUserObject() instanceof Album)
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
				if (selected.getUserObject() instanceof Album) {
					if (selected.getChildCount() > 0 && !evt.isShiftDown())
						selected = selected.getNextNode();
				} else if (selected.getUserObject() instanceof Track) {
					if (evt.isShiftDown())
						selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildBefore(selected);
					else
						selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildAfter(selected);
				} else if (selected.getUserObject() instanceof Metafile) {
					selected = (DefaultMutableTreeNode) selected.getParent();
					if (!evt.isShiftDown())
						selected = (DefaultMutableTreeNode) ((DefaultMutableTreeNode) selected.getParent()).getChildAfter(selected);
				}
				break;

			case KeyEvent.VK_F:
				if (matchingTree.getSelectionCount() != 1)
					break;
				if (selected.getUserObject() instanceof Album) {
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
				} else if (selected.getUserObject() instanceof Track) {
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
				} else if (selected.getUserObject() instanceof Metafile) {
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
				if (selected != null && selected.getUserObject() instanceof Album)
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
//		if (node.getUserObject() instanceof Album) {
//			/* expand all child nodes of this album */
//			Enumeration tracks = node.children();
//			while (tracks.hasMoreElements())
//				jTree1.expandPath(new TreePath(((DefaultMutableTreeNode) tracks.nextElement()).getPath()));
//		}
	}//GEN-LAST:event_matchingTreeTreeExpanded
        // Variables declaration - do not modify//GEN-BEGIN:variables
        private javax.swing.JScrollPane matchingScrollPane;
        private javax.swing.JTree matchingTree;
        // End of variables declaration//GEN-END:variables
}
