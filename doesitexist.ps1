# doesitexist.ps1 - test and log existence of file in list of computers.
#
# This script has the potential to modify or delete files on multiple machines.
# Please read and understand what it does before executing.
#
# This script requires two input files:
# $ComputerList - a CR/LF delimited list of target computers
# $FileList - a list of files to look for on each of the targets
#
# It outputs three files:
# $LogFile - a human-readable timestamped log of everything this script has done 
#       (not automatically deleted on subsequent executions of this script)
# $FailedComputerList - a CR/LF delimited list of targets that weren't reachable 
#       during the previous run (automatically deleted on subsequent executions 
#       but can be copied or renamed befhorehand to become the $ComputerList for 
#       the next run.
# $FailedFileList - a tab delimited list of files that couldn't be deleted (auto-
#       matically deleted each time this script executes).  The headers fields
#       are "Computer", "FilePath", and "UNC".
#

$ComputerList = Get-Content -Path c:\temp\doesitexist.computerlist.txt;
$FileList = Get-Content c:\temp\doesitexist.filelist.txt
$LogFile = 'c:\temp\doesitexist.log.txt'
$FailedComputerList = 'c:\temp\doesitexist.failedcomputerlist.txt'
$FailedFileList = 'c:\temp\doesitexist.failedfilelist.txt'

function Get-TimeStamp {
    (Get-Date -Format FileDateTimeUniversal)
}

# Stamp the logfile with a message that this run is beginning.
Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Beginning a run. WEeeeeeeeeEEEEe!";
# Make sure faileed computer list doesn't exist before we start testing and doing stuff.
if (Test-Path -Path "$FailedComputerList") {
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Deleting old failed targets in $($FailedComputerList)";
    Remove-Item "$FailedComputerList";    
} else {
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - No old failed targets list found... that's nice."
}

# Make sure failed file list doesn't exist and then initialize it with a header row before we start testing and doing stuff.
if (Test-Path -Path "$FailedFileList") {
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - And old failed file list exists! Deleting $($FailedComputerList) . . .";
    Remove-Item "$FailedFileList";
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Initializing new failed file list by adding header row to $($FailedFileList) . . .";
    Add-Content -Path $FailedFileList -Value "Computer`tFilePath`tUNC";
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - I think I've added the header row to $($FailedComputerList)."
} else {
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - No old failed file list found... that's nice."
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Initializing new failed file list by adding header row to $($FailedFileList) . . .";
    Add-Content -Path $FailedFileList -Value "Computer`tFilePath`tUNC";
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - I think I've added the header row to $($FailedFileList)."
}

# Iterate through the list of target computers, separated by CR/LF in the list file.
foreach ($Computer in $ComputerList) {
    # Only do the file stuff if the target computer is reachable.
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Testing if I can talk to $($Computer) . . ."
    if (Test-Connection -Computername $Computer -BufferSize 16 -Count 1 -Quiet) {
        # Iterate through the list of files that might be on the current target computer.
        foreach ($FilePath in $FileList) {
            # Test if the file exists.
            if (Test-Path -Path ("\\$Computer\c`$$FilePath" -f $Computer)) {
                Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - File \\$Computer\c`$$FilePath exists LOOLOMG!!!";
                #
                #
                #
                # IMPORTANT !!!! CUIDADO !!!!
                # The next comand DESTROYS DATA!!!!!!!!!!!!!!!!!!!!!!
                # Keep the "Remove-Item" command below commented out.
                # Only uncomment if you really want to delete the stuff in the $FileList on all machines in $ComputerList.
                #
                #
                #
                #Remove-Item "\\$Computer\c`$$FilePath";
                #
                #
                #
                # Test that any removal action succeeded and stamp the logfile with a message if the target file still exists.
                if (Test-Path -Path ("\\$Computer\c`$$FilePath" -f $Computer)) {
                    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - I tried to delete \\$Computer\c`$$FilePath but it's still there for some reason :("
                    Add-Content -Path $FailedFileList -Value "$Computer`t$FilePath`t\\$Computer\c`$$FilePath"
                    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Added $FilePath on $Computer to $($FailedFileList)"
                } else {
                    # If we get to this point, this script has deleted the target file.
                    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - I verified \\$Computer\c`$$FilePath is deleted now."
                }
            } else {
                # If we get to this point, the target file can't be found (or, if it's a directory, the directory is empty)
                Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - \\$Computer\c`$$FilePath doesn't exist or there are no files in that directory on $Computer."
            }
        }
    } else {
        # If we get to this point, the target computer wasn't reachable. Have you tried turning it off and back on again?
        Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Nope, it's not listening; adding $Computer to $FailedComputerList - that file is deleted and recreated each time this script runs."
        Add-Content -Path $FailedComputerList -Value "$Computer"
    }
    Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Done doing stuff with $Computer. Moving on!"
}
Add-Content -Path $LogFile -Value "$(Get-TimeStamp) - Done with everything I thought I should do. Whew."