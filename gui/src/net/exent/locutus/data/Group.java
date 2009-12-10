// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
package net.exent.locutus.data;

/**
 *
 * @author canidae
 */
public class Group {

	private String name;
	private int files;

	public Group(String name) {
		this.name = name;
		this.files = 0;
	}

	@Override
	public String toString() {
		/* XXX: turns out to be a bitch getting JTree to *not* go to a node starting with the typed character.
		 * solution? add \u200b which is a zero width character (ie. invisible) */
		return "\u200b" + getName() + " (" + getFiles() + " file" + (getFiles() == 1 ? ")" : "s)");
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the files
	 */
	public int getFiles() {
		return files;
	}

	/**
	 * @param files the files to set
	 */
	public void setFiles(int files) {
		this.files = files;
	}
}
