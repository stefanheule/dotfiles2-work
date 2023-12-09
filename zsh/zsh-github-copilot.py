#!/usr/bin/env python3

import sys
import os
import subprocess
import re

def main():

  buffer = sys.stdin.read()

  if not os.path.isfile('/usr/bin/ghs'):
    print('echo "Install GitHub CLI first:" && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install gh -y')
    return 0
  
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

  if 'unknown command "copilot" for "gh"' in error:
    print("echo 'Install github copilot extension first:' && /usr/bin/gh extension install github/gh-copilot")
    return 0

  if "Error: No valid OAuth token detected" in error:
    print("echo 'Authenticate with github first:' && /usr/bin/gh auth login --web -h github.com")
    return 0

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
  
  if output == "" and error != "":
    print("ERROR: " + error)
    return 0

  return 0


if __name__ == '__main__':
  sys.exit(main())
