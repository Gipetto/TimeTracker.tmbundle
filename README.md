## :: about

TimeTracker is a simple text based solution for tracking hours spent on projects.

TimeTracker works off a proprietary file extension but is stored in plain text. To get the full text highlighting and functionality automatically save your files with a .time extension. Everything still works if you manually set the file space to TimeTracker, but the file extension on the file will automatically tell TextMate to use the TimeTracker mode & highlighting. 

## :: commands

- **⌘⇧N - Now:** Inserts the current time rounded to the nearest 5 minutes.
- **⌘⇧A - Add:** Inserts a new line item and automatically inserts the start time.
	- Alternately, use **-⇥** to insert a new item.
- **⌘⇧T - Tally:** Tally's the time in the document. Will update already tallied items.
	- Tallies are rounded to the nearest 15 minutes.
	- Tallies will default to a minimum of 15 minutes unless they are 0.
- **⌘⇧C - Clean:** Cleans up the tallied time in the document.
- **⌘⇧H - Help:** Displays this help page.

**Legend:** ⇥ = tab, ⌃ = control, ⇧ = shift, ⌘ = command 

## :: example

The easiest way to demonstrate it might be to show examples.

**While recording data:**

	# My Project
	- my first task [8a-12p] 
	    - a note about this task
	- my second task [1-3:05p,4p-5p]

	# My Other Project
	- another task [1.25]

**Use Command-Shift-T to tally the time:**

	# My Project
	- my first task [8a-12p] (4.0)
	    - a note about this task
	- my second task [1-3:05p,4p-5p] (3.0)
	  ------------------
	  project: 7.0
 
	# My Other Project
	- another task [1.25] (1.25)
	  ------------------
	  project: 1.25
 
	====================
	  total: 8.25

## :: known bugs

- A lot of things will change. It is OK to save the data in a non-tallied state, but don't save the data in a tallied state yet. Too much might change that may make old files hard to read/manage.