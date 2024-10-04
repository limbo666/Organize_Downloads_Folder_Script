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

### Setup ###
1. Download the release package here.
2. Extract the files to a folder of your choice.
3. Open the Options.ini file and configure it based on your preferred organization method.
4. Run the script manually in PowerShell: <code>.\Organize-Downloads.ps1 </code> <br>
   Altenatively you can double click the `Organize-Downloads.ps1` file to run it if your system has the appropriate file association.  [Learn more about it](https://locall.host/run-with-powershell-double-click/)

Enjoy organizing your Downloads folder with ease!
