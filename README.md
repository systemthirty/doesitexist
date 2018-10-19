# doesitexist
PowerShell script to test if files exist on one or more remote computer (and, optionally, deletes those files)

This script has the potential to modify or delete files on multiple machines.
Please read the source code and understand what it does before executing.

This script requires two input files specified by the following parameters:
- **$ComputerList** - a CR/LF delimited list of target computers
- **$FileList** - a list of files to look for on each of the targets

It outputs three files specified by the following parameters:
- **$LogFile** - a human-readable timestamped log of everything this script has done (not automatically deleted on subsequent executions of this script)
- **$FailedComputerList** - a CR/LF delimited list of targets that weren't reachable during the previous run (automatically deleted on subsequent executions but can be copied or renamed befhorehand to become the $ComputerList for the next run.
- **$FailedFileList** - a tab delimited list of files that couldn't be deleted (automatically deleted each time this script executes).  The header fields are *Computer*, *FilePath*, and *UNC*.
