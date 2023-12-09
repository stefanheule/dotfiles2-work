#!/usr/bin/env python3

import sys
import os
import subprocess
import re

def main():

  buffer = sys.stdin.read()
  
  process = subprocess.Popen(['/usr/bin/gh', 'copilot', 'suggest', '-t', 'shell', buffer], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  
  output, error = process.communicate()

  # 7-bit C1 ANSI sequences
  ansi_escape = re.compile(r'''
      \x1B  # ESC
      (?:   # 7-bit C1 Fe (except CSI)
          [@-Z\\-_]
      |     # or [ for CSI, followed by a control sequence
          \[
          [0-?]*  # Parameter bytes
          [ -/]*  # Intermediate bytes
          [@-~]   # Final byte
      )
  ''', re.VERBOSE)
  output = ansi_escape.sub('', output)

  if "Suggestion not readily available. Please revise for better results." in output:
    print("No answer.")
    return 0
  
  idx = output.find('# Suggestion:')
  if idx != -1:
    output = output[idx + len('# Suggestion:'):]
  idx = output.find("\x0a\x0a\x1b\x37\x1b\x38\x0a\x3f")
  if idx != -1:
    output = output[:idx]

  output = output.strip()
  print(output)
  return 0


if __name__ == '__main__':
  sys.exit(main())
