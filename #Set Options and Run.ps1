# Function to create default Options.ini if it doesn't exist
function Ensure-DefaultOptionsIni {
    param (
        [string]$iniPath
    )
    if (-not (Test-Path $iniPath)) {
        $defaultContent = @"
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
IgnoreToday = True
; True - Ignore files created today
; False - Include files created today
"@
        Set-Content -Path $iniPath -Value $defaultContent
        Write-Host "Default Options.ini file created at $iniPath"
    }
}

# Function to read INI file (preserving comments)
function Get-IniContent ($filePath) {
    $ini = @{}
    $section = ""
    $comments = @()
    $allLines = Get-Content $filePath -Raw
    $allLines -split "`r`n" | ForEach-Object {
        $line = $_
        if ($line -match "^\[(.+)\]") {
            $section = $matches[1]
            $ini[$section] = @{}
            if ($comments) {
                $ini[$section]["__Comments"] = $comments
                $comments = @()
            }
        }
        elseif ($line -match "^\s*;(.*)") {
            $comments += $line
        }
        elseif ($line -match "(.+?)\s*=\s*(.*)") {
            $name, $value = $matches[1..2]
            $ini[$section][$name] = $value.Trim()
            if ($comments) {
                $ini[$section]["__Comments_$name"] = $comments
                $comments = @()
            }
        }
        elseif ($line.Trim() -ne "") {
            $comments += $line
        }
    }
    if ($comments) {
        $ini["__EndComments"] = $comments
    }
    return $ini
}

# Function to write INI file (preserving comments)
function Set-IniContent($ini, $filePath) {
    $content = @()
    foreach ($section in $ini.Keys) {
        if ($section -ne "__EndComments") {
            if ($section -ne "") {
                $content += "[$section]"
            }
            if ($ini[$section]["__Comments"]) {
                $content += $ini[$section]["__Comments"]
            }
            foreach ($key in $ini[$section].Keys) {
                if ($key -ne "__Comments" -and $key -notlike "__Comments_*") {
                    if ($ini[$section]["__Comments_$key"]) {
                        $content += $ini[$section]["__Comments_$key"]
                    }
                    $content += "$key = $($ini[$section][$key])"
                }
            }
        }
    }
    if ($ini["__EndComments"]) {
        $content += $ini["__EndComments"]
    }
    $content | Set-Content -Path $filePath
}

# Set up paths
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$iniPath = Join-Path $scriptPath "Options.ini"

# Ensure Options.ini exists with default content
Ensure-DefaultOptionsIni -iniPath $iniPath

# Read the INI file
$iniContent = Get-IniContent $iniPath


# Create the form
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Organize Downloads"
$form.Size = New-Object System.Drawing.Size(350,300)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.BackColor= "Tan"
$form.StartPosition = "CenterScreen"

# Set form icon
$iconPath = Join-Path $scriptPath "tool.ico"
if (Test-Path $iconPath) {
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}

# Explore Downloads Button
$exploreButton = New-Object System.Windows.Forms.Button
$exploreButton.Location = New-Object System.Drawing.Point(200,10)
$exploreButton.Size = New-Object System.Drawing.Size(120,23)
$exploreButton.Text = "Explore Downloads"
$exploreButton.BackColor="Snow"
$exploreButton.Add_Click({
    Start-Process (Join-Path $env:USERPROFILE "Downloads")
})
$form.Controls.Add($exploreButton)

# Method ComboBox
$methodLabel = New-Object System.Windows.Forms.Label
$methodLabel.Location = New-Object System.Drawing.Point(10,50)
$methodLabel.Size = New-Object System.Drawing.Size(280,20)
$methodLabel.Text = "Method:"
$form.Controls.Add($methodLabel)

$methodComboBox = New-Object System.Windows.Forms.ComboBox
$methodComboBox.Location = New-Object System.Drawing.Point(10,70)
$methodComboBox.Size = New-Object System.Drawing.Size(260,20)
$methodComboBox.Items.AddRange(@("Group", "File", "Date"))
$methodComboBox.SelectedItem = $iniContent["Settings"]["Method"]
$form.Controls.Add($methodComboBox)

# Explore CheckBox
$exploreCheckBox = New-Object System.Windows.Forms.CheckBox
$exploreCheckBox.Location = New-Object System.Drawing.Point(10,100)
$exploreCheckBox.Size = New-Object System.Drawing.Size(280,20)
$exploreCheckBox.Text = "Explore Downloads Folder After Execute"
$exploreCheckBox.Checked = $iniContent["Settings"]["Explore"] -eq "True"
$form.Controls.Add($exploreCheckBox)

# Log CheckBox
$logCheckBox = New-Object System.Windows.Forms.CheckBox
$logCheckBox.Location = New-Object System.Drawing.Point(10,130)
$logCheckBox.Size = New-Object System.Drawing.Size(280,20)
$logCheckBox.Text = "Log Actions"
$logCheckBox.Checked = $iniContent["Settings"]["Log"] -eq "True"
$form.Controls.Add($logCheckBox)

# IgnoreToday CheckBox
$ignoreTodayCheckBox = New-Object System.Windows.Forms.CheckBox
$ignoreTodayCheckBox.Location = New-Object System.Drawing.Point(10,160)
$ignoreTodayCheckBox.Size = New-Object System.Drawing.Size(280,20)
$ignoreTodayCheckBox.Text = "Ignore Today's Downloads"
$ignoreTodayCheckBox.Checked = $iniContent["Settings"]["IgnoreToday"] -eq "True"
$form.Controls.Add($ignoreTodayCheckBox)

# Function to save INI content
function Save-IniContent {
    $iniContent["Settings"]["Method"] = $methodComboBox.SelectedItem
    $iniContent["Settings"]["Explore"] = $exploreCheckBox.Checked.ToString()
    $iniContent["Settings"]["Log"] = $logCheckBox.Checked.ToString()
    $iniContent["Settings"]["IgnoreToday"] = $ignoreTodayCheckBox.Checked.ToString()
    Set-IniContent $iniContent $iniPath
}

# Save and Close Button
$saveCloseButton = New-Object System.Windows.Forms.Button
$saveCloseButton.Location = New-Object System.Drawing.Point(120,220)
$saveCloseButton.Size = New-Object System.Drawing.Size(100,23)
$saveCloseButton.BackColor="Snow"
$saveCloseButton.Text = "Save && Close"
$saveCloseButton.Add_Click({
    Save-IniContent
    $form.Close()
})
$form.Controls.Add($saveCloseButton)

# Save and Execute Button
$saveExecuteButton = New-Object System.Windows.Forms.Button
$saveExecuteButton.Location = New-Object System.Drawing.Point(230,220)
$saveExecuteButton.Size = New-Object System.Drawing.Size(100,23)
$saveExecuteButton.BackColor="Snow"
$saveExecuteButton.Text = "Save && Execute"
$saveExecuteButton.Add_Click({
    Save-IniContent
    $form.Close()
    Start-Sleep -Milliseconds 500
    $organizerPath = Join-Path $scriptPath "Organize-Downloads.ps1"
    if (Test-Path $organizerPath) {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$organizerPath`""
    } else {
        [System.Windows.Forms.MessageBox]::Show("Organize-Downloads.ps1 not found in the script directory.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($saveExecuteButton)

# Show the form
$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()