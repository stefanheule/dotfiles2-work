on fullSizeMain(windowToResize)
	tell application "System Events"
		set bounds of windowToResize to {0, 25, 2475, 1415}
	end tell
end fullSizeMain

tell application "System Events"
	tell process "iTerm2"
		repeat with w from 1 to count windows
			tell window w
				set position to {-1430, 777}
				set size to {1411, 923}
			end tell
		end repeat
	end tell
end tell

tell application "System Events" to tell process "Code"
	repeat with w from 1 to count windows
		tell window w
			set position to {0, 25}
			set size to {2475, 1415}
		end tell
	end repeat
end tell


tell application "System Events" to tell process "sublime_text"
	repeat with w from 1 to count windows
		tell window w
			set position to {356, 75}
			set size to {1722, 1261}
		end tell
	end repeat
end tell

tell application "Google Chrome"
	set targetURLPart to "https://www.test.ch/"
	set urlFoundInWindow to false
	
	-- Loop through every window
	repeat with w from 1 to count windows
		set theWindow to window w
		set urlFoundInWindow to false
		
		-- Loop through every tab in the current window
		repeat with t from 1 to count tabs of theWindow
			set theTab to tab t of theWindow
			if URL of theTab contains targetURLPart then
				set urlFoundInWindow to true
				exit repeat -- No need to check other tabs in this window
			end if
		end repeat
		
		-- Move
		if urlFoundInWindow then
			my fullSizeMain(theWindow)
		else
			set bounds of theWindow to {-1406, -604, -50, 650}
		end if
	end repeat
end tell

tell application "System Events"
    set frontmost of process "Chrome" to true
end tell