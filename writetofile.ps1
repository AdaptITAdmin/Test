# Note that you will need to specify NoNewLine for the first entry as well
# Set-Location -Path "/test/copytest/fruits.txt"
# get-location
'BlueBerry;' | Out-File -FilePath "fruits.txt" -NoNewline

# Appending more berries
'StrawBerry;' | Out-File -FilePath "fruits.txt" -Append -NoNewline
'BlackBerry;' | Out-File -FilePath "fruits.txt" -Append -NoNewline
'RaspBerry;' | Out-File -FilePath  "fruits.txt" -Append -NoNewline
'CranBerry;' | Out-File -FilePath  "fruits.txt" -Append -NoNewline
