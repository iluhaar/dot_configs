# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\tokyo.omp.json" | Invoke-Expression
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\zash.omp.json" | Invoke-Expression

$pers = 'C:\Users\iluha\personal'

#Alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias lg lazygit
Set-Alias gt git
Set-Alias -Name ccp -Value Copy-CurrentPath -Description "Alias for Copy-CurrentPath"

function convert2gif {
    param (
        [string]$inputFileName,
        [Alias('c')]
        [switch]$copyToClipboard
    )

    # Check if the input file exists
    if (!(Test-Path $inputFileName)) {
        Write-Output "File $inputFileName not found."
        return
    }

    # Define the output GIF file name
    $outputFileName = [System.IO.Path]::ChangeExtension($inputFileName, "gif")

    # Get today's date in yyyy-MM-dd format
    $todayFolder = Get-Date -Format "yyyy-MM-dd"

    # Create base gif directory if it doesn't exist
    if (!(Test-Path "./gif")) {
        New-Item -ItemType Directory -Path "./gif" -Force
    }

    # Create today's date folder if it doesn't exist
    $dateFolder = "$todayFolder"
    if (!(Test-Path $dateFolder)) {
        New-Item -ItemType Directory -Path $dateFolder -Force
    }

    # Run the FFmpeg command to convert the MP4 to GIF
    ffmpeg -i $inputFileName -vf "fps=10,scale=1200:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "./gif/$dateFolder/$outputFileName"

    Write-Output "Conversion complete: $dateFolder/$outputFileName"

    # Copy to clipboard if the flag is set
    if ($copyToClipboard) {
        Get-Item "$dateFolder/$outputFileName" | Set-Clipboard
        Write-Output "GIF $outputFileName copied to clipboard"
    }
}

function convertWebp2png {
    param (
        [string]$inputFileName
    )

    # Check if the input file exists
    if (!(Test-Path $inputFileName)) {
        Write-Output "File $inputFileName not found."
        return
    }

    # Define the output GIF file name
    $outputFileName = [System.IO.Path]::ChangeExtension($inputFileName, "png")

    # Run FFmpeg command to convert the Webp to PNG

    ffmpeg -i $inputFileName $outputFileName

    Write-Output "Conversion complete: $outputFileName"
}

function phelp {
    Write-Host "Custom commands:"
    Write-Host "-----------------------------"
    Write-Host "convert2gif: accepts file name, or full path to the file and converts mp4 to gif"
    Write-Host "-----------------------------"
    Write-Host "convertWebp2png: accepts file name, or full path to the file and converts webp to png"
    Write-Host "-----------------------------"
    Write-Host "work: opens slack, 3kit directory, run x-mouse"
    Write-Host "-----------------------------"
    Write-Host "kill3000: kills process on port 3000"
    Write-Host "-----------------------------"
    Write-Host "GetBranchesDiff: receives two branch names ex: GetBranchesDiff main dev"
    Write-Host "-----------------------------"
    Write-Host "ccp: copies active path"
}

function kill3000 {
    $processInfo = netstat -ano | findstr ":3000"
    if ($processInfo) {
        $pid = ($processInfo -split ' ')[-1]
        Write-Host "Killing process with PID: $pid"
        taskkill /PID $pid /F
    } else {
        Write-Host "No process found using port 3000"
    }
}

function GetBranchesDiff {
    param(
        [string]$firstBranch,
        [string]$secondBranch
    )

    # Check if parameters were provided
    if ([string]::IsNullOrEmpty($firstBranch)) {
        Write-Output "First branch parameter is required."
        return
    }

    if ([string]::IsNullOrEmpty($secondBranch)) {
        Write-Output "Second branch parameter is required."
        return
    }

    # Check if branches exist in Git
    $firstBranchExists = git rev-parse --verify --quiet "origin/$firstBranch"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Branch '$firstBranch' not found in remote 'origin'."
        return
    }

    $secondBranchExists = git rev-parse --verify --quiet "origin/$secondBranch"
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Branch '$secondBranch' not found in remote 'origin'."
        return
    }

    # Show diff between branches
    git diff --stat "origin/$firstBranch" "origin/$secondBranch"
}

function Find-LargestFiles {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = ".",

        [Parameter(Mandatory=$false)]
        [string]$FilePattern = "*.tsx",

        [Parameter(Mandatory=$false)]
        [int]$Top = 10
    )

    Write-Host "Searching for $FilePattern files in $Path..." -ForegroundColor Cyan

    $files = Get-ChildItem -Path $Path -Recurse -File -Filter $FilePattern -ErrorAction SilentlyContinue

    if ($files.Count -eq 0) {
        Write-Host "No matching files found." -ForegroundColor Yellow
        return
    }

    Write-Host "Found $($files.Count) matching files. Counting lines..." -ForegroundColor Cyan

    $results = foreach ($file in $files) {
        try {
            $lineCount = (Get-Content $file.FullName -ErrorAction Stop | Measure-Object -Line).Lines
            [PSCustomObject]@{
                FileName = $file.FullName
                LineCount = $lineCount
            }
        }
        catch {
            Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
        }
    }

    $sortedResults = $results | Sort-Object LineCount -Descending | Select-Object -First $Top

    Write-Host "Top $Top files by line count:" -ForegroundColor Green
    $sortedResults | Format-Table -AutoSize
}

function Copy-CurrentPath {
    <#
    .SYNOPSIS
        Copies the current working directory path to the Windows clipboard.
    .DESCRIPTION
        This function retrieves the full path of the current directory
        and sends it directly to the system clipboard using the 'clip' utility.
        This allows for quick pasting of the path into other applications.
    .EXAMPLE
        Copy-CurrentPath
        # Copies "C:\Users\YourUser\Documents" (or your current path) to clipboard.
    #>
    [CmdletBinding()]
    param()

    try {
        # Get the current location object and extract its Path property
        $currentPath = (Get-Location).Path

        # Pipe the path string to the 'clip' utility, which puts it on the clipboard
        $currentPath | clip

        Write-Host "Current path '$currentPath' copied to clipboard." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to copy path to clipboard: $($_.Exception.Message)"
    }
}

function Organize-GifFilesByDate {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$false,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$Path = (Get-Location).Path,

        [Parameter(Mandatory=$false)]
        [string]$FileFilter = "*.gif"
    )

    Process {
        Write-Host "Starting file organization in '$Path' for files matching '$FileFilter'..."

        # Get all files matching the filter in the specified path
        $filesToProcess = Get-ChildItem -Path $Path -Filter $FileFilter -File

        if (-not $filesToProcess) {
            Write-Warning "No files matching '$FileFilter' found in '$Path'. Exiting."
            return
        }

        foreach ($file in $filesToProcess) {
            # Extract the base name of the file (without extension)
            $fileNameWithoutExtension = $file.BaseName

            # Attempt to extract the date part from the filename
            # It tries to match "YYYY-MM-DD" followed by a space or underscore
            $dateMatch = $fileNameWithoutExtension | Select-String -Pattern "(\d{4}-\d{2}-\d{2})[ _]"

            if ($dateMatch) {
                # Get the matched date string
                $datePart = $dateMatch.Matches[0].Groups[1].Value

                # Define the full path for the target directory
                $targetDirectory = Join-Path -Path $Path -ChildPath $datePart

                # Check if the target directory exists and create if not, respecting WhatIf/Confirm
                if (-not (Test-Path -Path $targetDirectory -PathType Container)) {
                    if ($PSCmdlet.ShouldProcess("Create directory '$targetDirectory'", "Creating new directory for date-matched files")) {
                        Write-Host "Creating new directory: $targetDirectory"
                        try {
                            New-Item -ItemType Directory -Path $targetDirectory -ErrorAction Stop | Out-Null
                        } catch {
                            Write-Error "Failed to create directory '$targetDirectory': $($_.Exception.Message)"
                            continue # Skip to the next file if directory creation fails
                        }
                    } else {
                        Write-Verbose "Operation cancelled: Create directory '$targetDirectory'"
                        continue # Skip to the next file if WhatIf/Confirm prevents creation
                    }
                }

                # Define the full path for the destination file
                $destinationPath = Join-Path -Path $targetDirectory -ChildPath $file.Name

                # Move the file, respecting WhatIf/Confirm
                if ($PSCmdlet.ShouldProcess("Move '$($file.Name)' to '$($targetDirectory)'", "Moving date-matched file")) {
                    Write-Host "Moving '$($file.Name)' to '$($targetDirectory)'"
                    try {
                        Move-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
                    } catch {
                        Write-Error "Failed to move '$($file.Name)': $($_.Exception.Message)"
                    }
                } else {
                    Write-Verbose "Operation cancelled: Move file '$($file.Name)'"
                }
            } else {
                # If date format is not found, move to an "other" folder
                $otherDirectory = Join-Path -Path $Path -ChildPath "other"

                # Check if the "other" directory exists and create if not
                if (-not (Test-Path -Path $otherDirectory -PathType Container)) {
                    if ($PSCmdlet.ShouldProcess("Create directory '$otherDirectory'", "Creating 'other' directory for non-date-matched files")) {
                        Write-Host "Creating new directory: $otherDirectory"
                        try {
                            New-Item -ItemType Directory -Path $otherDirectory -ErrorAction Stop | Out-Null
                        } catch {
                            Write-Error "Failed to create directory '$otherDirectory': $($_.Exception.Message)"
                            continue # Skip to the next file if directory creation fails
                        }
                    } else {
                        Write-Verbose "Operation cancelled: Create directory '$otherDirectory'"
                        continue # Skip to the next file if WhatIf/Confirm prevents creation
                    }
                }

                # Define the full path for the destination file in the 'other' directory
                $destinationPath = Join-Path -Path $otherDirectory -ChildPath $file.Name

                # Move the file to the 'other' folder
                if ($PSCmdlet.ShouldProcess("Move '$($file.Name)' to '$($otherDirectory)'", "Moving non-date-matched file")) {
                    Write-Warning "Could not extract date from filename '$($file.Name)'. Moving to '$($otherDirectory)'."
                    try {
                        Move-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
                    } catch {
                        Write-Error "Failed to move '$($file.Name)' to 'other' directory: $($_.Exception.Message)"
                    }
                } else {
                    Write-Verbose "Operation cancelled: Move file '$($file.Name)' to 'other' directory"
                }
            }
        }
        Write-Host "File organization complete."
    }
}
