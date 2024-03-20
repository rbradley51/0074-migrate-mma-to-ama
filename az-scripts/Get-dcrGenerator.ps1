$url = "https://raw.githubusercontent.com/username/repository/master/script.ps1"
$output = "C:\\path\\to\\your\\directory\\script.ps1"

Invoke-WebRequest -Uri $url -OutFile $output
