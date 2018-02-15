#5.1.4.ps1

# A folder contains numerous training videos in the form "The.Workplace.S24E01.HDTV.x264-LOL.mp4"
# that you want to rewrite as "The Workplace S24E01.mp4"

$pattern = "(?<PROGRAM>.+\.)(?<EPISODE>\w+\d{2}\w+\d{2})(.+)(?<EXTENSION>\.\w+$)"
$folder = "C:\Pshell\Labs\Lab_5\videos"

Get-ChildItem -Path $folder | ForEach-Object {
 if ($_.Name -Match $pattern) {
  $NewFileName = ($matches.PROGRAM).Replace("."," ") + $matches.EPISODE + $matches.EXTENSION
  $NewFileFullName = Join-Path $_.DirectoryName $newFileName
  Copy-Item -path $_.FullName -Destination $NewFileFullName -Verbose -Force
 }
}
