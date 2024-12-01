<#
Run Microsoft Visual Studio Compiller cl.exe.
Place 'PSVSCompile' directory to directory one of list $env:PSModulePath.
Place files from 'vscode-exmpales' to project directory $PROJECT_DIR/.vscode.
#>

function Invoke-MSVSCompiller {
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [String]
        [ValidateNotNullOrEmpty()]
        $InitEnvScript,
        [Parameter(Mandatory=$True, Position=1)]
        [ValidateNotNullOrEmpty()]
        $BuildDirectory,
        [Parameter(Mandatory=$True, Position=3)]
        [ValidateNotNullOrEmpty()]
        $CompillerName,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]
        $CompillerArgs
    )

    # Init environment from MSVS run script.
    # For example:
    #   C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat
    Set-EnvironmentFromBatch -BatchFile $InitEnvScript

    # Create build directory.
    if (-not (Test-Path $BuildDirectory)) {
        New-Item -Path $BuildDirectory -ItemType Directory -Force
    }

    return Start-Process -FilePath $CompillerName -ArgumentList $CompillerArgs -NoNewWindow
}

function Set-EnvironmentFromBatch() {
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [String]
        [ValidateNotNullOrEmpty()]
        $BatchFile       
    )
    $cmd = '"' + ${BatchFile} + '" & set'
    cmd /C "$cmd" |
    Where-Object {$_ -notmatch "^PROMPT="} |
    ForEach-Object {
        if ($_ -match "(\w+)=(.*)") {
            $Name = $matches[1]
            $Value = $matches[2]
            [System.Environment]::SetEnvironmentVariable($Name, $Value)
        }
    }
}
