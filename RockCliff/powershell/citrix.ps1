if ($PSVersionTable.PSVersion -ne [Version]"5.1") {
    # Re-launch as version 5 if we're not already
    powershell -Version 5.1 -File $MyInvocation.MyCommand.Definition
    exit
  }
  