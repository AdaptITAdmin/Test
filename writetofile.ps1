# Note that you will need to specify NoNewLine for the first entry as well
'BlueBerry;' | Out-File -FilePath C:\temp\fruits.txt -NoNewline

# Appending more berries
'StrawBerry;' | Out-File -FilePath C:\temp\fruits.txt -Append -NoNewline
'BlackBerry;' | Out-File -FilePath C:\temp\fruits.txt -Append -NoNewline
'RaspBerry;' | Out-File -FilePath C:\temp\fruits.txt -Append -NoNewline
'CranBerry;' | Out-File -FilePath C:\temp\fruits.txt -Append -NoNewline
