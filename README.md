# Organize Downloads Folder Script
**A PowerShell script to organize your Downloads folder based on file types, creation dates, or custom groupings.**

This script allows you to organize files in your Downloads folder according to three different methods: 
by file extension, by file group (e.g., images, documents, compressed files), or by creation date. Additionally, the script is highly configurable via an `Options.ini` file.

### Features ###

 - Organize by File Group: Sorts images, documents, and compressed files into separate folders.
 - Organize by File Extension: Creates individual folders for each file extension in your Downloads folder. - 
 - Organize by Date: Moves files into folders based on their creation date.
 - File Explorer Integration: Automatically opens the Downloads folder before starting the organization process (configurable).
 - Logging: Records the organization process in a log file (optional).
 - Option to ignore today's download files for easy access.
 - GUI to select options. Offered as seperate launcher script `#Set Options and Run.ps1`
   

### Configuration ###

The script comes with an Options.ini file that allows you to customize how your Downloads folder is organized:
 
    [Settings]
    ; Organize by:
    ; Date - Organizes files by creation date (Downloads_DD.MM.YY)
    ; File - Organizes files by individual file extensions
    ; Group - Groups images, compressed files, and documents in specific folders
    Method = Group
    
    ; Explorer Integration
    ; True - Opens the file explorer to downloads folder before operation
    ; False - No File Explorer integration
    Explore = True
    
    ; Log actions
    ; True - Log enabled
    ; False - Log Disabled
    Log = True
    ; Ignore today's downloads
    ; True - Ignore files created today
    ; False - Include files created today
    IgnoreToday = True
For easy use the file `#Set Options and Run.ps1` offers an interface to set all these options and run the organizer script.
![image](https://github.com/user-attachments/assets/6911e68a-e48e-46a9-b143-2968dd46fbda)


### Setup and Run ###
1. Download the release package here.
2. Extract the files to a folder of your choice.\
3. Execute select A (recommended) or B:<br>
    **A.** Run the file `#Set Options and Run.ps1` by right clicking and selecting `Run with Powershell` or double clicking if your system has the appropriate file association or by typing in PowerShell: <code>.\\#Set Options and Run.ps1</code> <br>
   <br>
     **B.** Open the file `Options.ini` and configure it based on your preferred organization method.<br>
      Run the file `Organize-Downloads.ps1` by right clicking and selecting `Run with Powershell` or double clicking if your system has the appropriate file association or by typing in PowerShell: <code>.\Organize-Downloads.ps1 </code>. <br> 
 <br> 
Learn more about file association https://locall.host/run-with-powershell-double-click/ \
 
Enjoy organizing your Downloads folder with ease!
