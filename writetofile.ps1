$date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
New-Item -ItemType file -Path "$(System.DefaultWorkingDirectory)/$date.txt"