delay 1

tell application "System Events"
  set frontApp to first application process whose frontmost is true
  set appName to name of frontApp
  
  tell front window of frontApp
    set windowPosition to position
    set windowSize to size
  end tell
end tell

set {xPos, yPos} to windowPosition
set {widthVal, heightVal} to windowSize

return "Application Name: " & appName & "\n" & "Position (x, y): (" & xPos & ", " & yPos & ")" & "\n" & "Size (width, height): (" & widthVal & ", " & heightVal & ")"
