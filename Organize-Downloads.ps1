# Define paths
$DownloadsFolder = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("UserProfile"), "Downloads")
$LogFilePath = [System.IO.Path]::Combine($PSScriptRoot, "MoveFilesLog.txt")
$IniFilePath = [System.IO.Path]::Combine($PSScriptRoot, "Options.ini")

# Initialize logging based on ini settings
$LoggingEnabled = $true

# Function to log information (conditionally based on logging setting)
function Write-Log {
    param(
        [string]$Message
    )
    if ($LoggingEnabled) {
        $TimeStamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
        $LogMessage = "$TimeStamp - $Message"
        Add-Content -Path $LogFilePath -Value $LogMessage
    }
}

# Function to create the default ini file if it doesn't exist
function Create-DefaultIni {
    if (-not (Test-Path -Path $IniFilePath)) {
        $IniContent = @"
[Settings]
Method = Group
; Organize by:
; Date - Organizes files by creation date (Downloads_DD.MM.YY)
; File - Organizes files by individual file extensions
; Group - Groups images, compressed files, and documents in specific folders
Explore = True
; True - Opens the file explorer to downloads folder before operation
; False - No File Explorer integration
Log = True
; True - Log enabled
; False - Log Disabled
"@
        Set-Content -Path $IniFilePath -Value $IniContent
        Write-Log "Options.ini created with default settings (Method = Group, Explore = True, Log = True)."
    }
}

# Function to read settings from the ini file
function Read-Settings {
    $IniContent = Get-Content -Path $IniFilePath
    $IniSettings = @{}
    foreach ($Line in $IniContent) {
        if ($Line -match "^\s*(\w+)\s*=\s*(\w+)\s*$") {
            $IniSettings[$matches[1]] = $matches[2]
        }
    }
    return $IniSettings
}

# Function to open File Explorer at the Downloads folder
function Open-Explorer {
    Write-Log "Opening File Explorer at Downloads folder."
    Start-Process explorer.exe $DownloadsFolder
}

# Function to move files based on Grouping (Images, Compressed, Documents)
function Move-ByGroup {
    Write-Log "Organizing files by Group (Images, Compressed, Documents)."

    # Define groups of file types
    $ImageExtensions = @("jpg", "jpeg", "png", "webp", "bmp", "gif", "psd", "raw", "ai", "eps")
    $CompressedExtensions = @("zip", "tar", "rar", "7z")
    $DocumentExtensions = @("xls", "doc", "pdf", "xlsx", "docx", "ppt", "pptx")

    $TotalFilesMoved = 0
    $TotalErrors = 0

    $Files = Get-ChildItem -Path $DownloadsFolder -File

    foreach ($File in $Files) {
        try {
            $Extension = $File.Extension.TrimStart('.').ToLower()
            $DestinationFolder = ""

            # Check if file is an image
            if ($ImageExtensions -contains $Extension) {
                $DestinationFolder = [System.IO.Path]::Combine($DownloadsFolder, "Images_Files")
            }
            # Check if file is a compressed file
            elseif ($CompressedExtensions -contains $Extension) {
                $DestinationFolder = [System.IO.Path]::Combine($DownloadsFolder, "Compressed_Files")
            }
            # Check if file is a document
            elseif ($DocumentExtensions -contains $Extension) {
                $DestinationFolder = [System.IO.Path]::Combine($DownloadsFolder, "Documents_Files")
            }
            else {
                $DestinationFolder = [System.IO.Path]::Combine($DownloadsFolder, $Extension + "_Files")
            }

            # Create the destination folder if it doesn't exist
            if (-not (Test-Path -Path $DestinationFolder)) {
                New-Item -Path $DestinationFolder -ItemType Directory | Out-Null
            }

            # Move the file
            Move-Item -Path $File.FullName -Destination $DestinationFolder

            # Log the successful move
            Write-Log "File moved: $($File.Name) to $DestinationFolder"
            $TotalFilesMoved++
        } catch {
            # Log the error
            Write-Log "Error moving file: $($File.Name) - $($_.Exception.Message)"
            $TotalErrors++
        }
    }

    # Log final summary
    Write-Log "Files organized by Group. Total files moved: $TotalFilesMoved. Total errors: $TotalErrors."
}

# Function to move files by individual file extension
function Move-ByExtension {
    Write-Log "Organizing files by file extension."

    $TotalFilesMoved = 0
    $TotalErrors = 0

    $Files = Get-ChildItem -Path $DownloadsFolder -File

    foreach ($File in $Files) {
        try {
            $Extension = $File.Extension.TrimStart('.').ToUpper()
            $DestinationFolder = [System.IO.Path]::Combine($DownloadsFolder, $Extension + "_Files")

            # Create the destination folder if it doesn't exist
            if (-not (Test-Path -Path $DestinationFolder)) {
                New-Item -Path $DestinationFolder -ItemType Directory | Out-Null
            }

            # Move the file
            Move-Item -Path $File.FullName -Destination $DestinationFolder

            # Log the successful move
            Write-Log "File moved: $($File.Name) to $DestinationFolder"
            $TotalFilesMoved++
        } catch {
            # Log the error
            Write-Log "Error moving file: $($File.Name) - $($_.Exception.Message)"
            $TotalErrors++
        }
    }

    # Log final summary
    Write-Log "Files organized by file extension. Total files moved: $TotalFilesMoved. Total errors: $TotalErrors."
}

# Function to move files by creation date
function Move-ByDate {
    Write-Log "Organizing files by creation date."

    $Today = Get-Date -Format "dd.MM.yy"
    $TotalFilesMoved = 0
    $TotalErrors = 0

    $Files = Get-ChildItem -Path $DownloadsFolder -File

    foreach ($File in $Files) {
        try {
            $CreationDate = $File.CreationTime.ToString("dd.MM.yy")

            # Skip files created today
            if ($CreationDate -eq $Today) {
                continue
            }

            # Define the destination folder
            $DestinationFolder = [System.IO.Path]::Combine($DownloadsFolder, "Downloads_$CreationDate")

            # Create the destination folder if it doesn't exist
            if (-not (Test-Path -Path $DestinationFolder)) {
                New-Item -Path $DestinationFolder -ItemType Directory | Out-Null
            }

            # Move the file
            Move-Item -Path $File.FullName -Destination $DestinationFolder

            # Log the successful move
            Write-Log "File moved: $($File.Name) to $DestinationFolder"
            $TotalFilesMoved++
        } catch {
            # Log the error
            Write-Log "Error moving file: $($File.Name) - $($_.Exception.Message)"
            $TotalErrors++
        }
    }

    # Log final summary
    Write-Log "Files organized by date. Total files moved: $TotalFilesMoved. Total errors: $TotalErrors."
}

# Main script execution starts here

# Create the ini file if it doesn't exist
Create-DefaultIni

# Read the ini file settings
$Settings = Read-Settings
$Method = $Settings["Method"]
$Explore = $Settings["Explore"]
$Log = $Settings["Log"]

# Check if logging is enabled
$LoggingEnabled = if ($Log -eq "False") { $false } else { $true }

# Log the selected method and whether File Explorer will open
Write-Log "Selected organization method: $Method"
Write-Log "File Explorer integration: $Explore"
Write-Log "Logging enabled: $LoggingEnabled"

# Open File Explorer if the Explore setting is True
if ($Explore -eq "True") {
    Open-Explorer
}

# Organize files based on the selected method
switch ($Method) {
    "Date" { Move-ByDate }
    "File" { Move-ByExtension }
    "Group" { Move-ByGroup }
    default { Write-Log "Invalid method in ini file. Using default (Group)." ; Move-ByGroup }
}

Write-Log "Process completed. Log file located at: $LogFilePath"
