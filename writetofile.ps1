# Note that you will need to specify NoNewLine for the first entry as well
$path = 'test/copytest/fruits.txt'
get-location
# 'BlueBerry;' | Out-File -FilePath $path -NoNewline

# # Appending more berries
# 'StrawBerry;' | Out-File -FilePath $path -Append -NoNewline
# 'BlackBerry;' | Out-File -FilePath $path -Append -NoNewline
# 'RaspBerry;' | Out-File -FilePath  $path -Append -NoNewline
# 'CranBerry;' | Out-File -FilePath  $path -Append -NoNewline
