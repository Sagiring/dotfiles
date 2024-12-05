Set-Alias gsudo sudo

function setWslNetsh {
    param (
        $Port
    )
    sudo netsh interface portproxy add v4tov4 listenport=$Port connectaddress=localhost connectport=$Port listenaddress=10.21.237.247 protocol=tcp
    Write-Output "✔ Port($Port) now is out!"
}

function unsetWslNetsh {
    param (
        $Port
    )
    sudo netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=10.21.237.247 protocol=tcp
    Write-Output "✔ Port($Port) now is not out!"
}

Set-Alias wsl-netsh-set setWslNetsh
Set-Alias wsl-netsh-unset unsetWslNetsh


function setFWPort {
    param (
        $Port
    )
    $PortWSL = "Port-" + $Port
    $NetFirewallRule = Get-NetFirewallRule
    if (-not $NetFirewallRule.DisplayName.Contains($PortWSL)) {
        # sudo Remove-NetFireWallRule -DisplayName $Port4WSL
        sudo New-NetFireWallRule -DisplayName $PortWSL -Direction Outbound -LocalPort $Port -Action Allow -Protocol TCP 
        sudo New-NetFireWallRule -DisplayName $PortWSL -Direction Inbound -LocalPort $Port -Action Allow -Protocol TCP  
        # sudo New-NetFireWallRule -DisplayName $PortWSL -Direction Outbound -LocalPort $Port -Action Allow -Protocol TCP  -IPVersion IPv6
        # sudo New-NetFireWallRule -DisplayName $PortWSL -Direction Inbound -LocalPort $Port -Action Allow -Protocol TCP  -IPVersion IPv6
        Write-Output "✔ New rule for (Port: $Port)!"
    }
    else {
        Write-Output "✔ Rule for (Port: $Port) exists!"
    }
}
function unsetFWPort {
    param (
        $Port
    )
    $PortWSL = "Port-" + $Port
    $NetFirewallRule = Get-NetFirewallRule
    if (-not $NetFirewallRule.DisplayName.Contains($PortWSL)) {
        Write-Output "✔ Rule for (Port: $Port) not exists!"
    }
    else {
        # sudo Remove-NetFireWallRule -DisplayName $PortWSL -IPVersion IPv6
        sudo Remove-NetFireWallRule -DisplayName $PortWSL
        Write-Output "✔ Rule for (Port: $Port) removed!"
    }
}

Set-Alias fw-port-set setFWPort
Set-Alias fw-port-unset unsetFWPort