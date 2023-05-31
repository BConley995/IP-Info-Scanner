$CompName = $env:COMPUTERNAME
Function IIP {
    $global:identity = "I"

    $ITarget = Get-ChildItem "C:\Program Files*\jDummy\I*\" -ErrorAction SilentlyContinue
    $DefI = Resolve-Path $ITarget | Select-Object -Last 1 -ErrorAction SilentlyContinue
        

    $HIPfilePath = "$DefI\Config\IPConfig.xml"

    $xPathClient = "//IPCommsLink[@CommsLinkID='Client']/@RemoteHost"
    $xPathServer = "//IPCommsLinkListener[@CommsLinkID='Server']/RemoteHostIP/@RemoteHost"

    $xmlContent = Get-Content $HIPfilePath -Raw
    $xmlDocument = New-Object -TypeName System.Xml.XmlDocument
    $xmlDocument.LoadXml($xmlContent)

    $remoteHostNodesClient = Select-Xml -Xml $xmlDocument -XPath $xPathClient
    $remoteHostNodesServer = Select-Xml -Xml $xmlDocument -XPath $xPathServer

    if ($remoteHostNodesClient) {
        $validIPsClient = @()
        foreach ($node in $remoteHostNodesClient) {
            $ip = $node.Node.Value
            if ($ip -notmatch "^(192\.168|127\.0)") {
                $validIPsClient += $ip
            }
        }

        if ($validIPsClient) {
            $global:clientRemoteHostIP = $validIPsClient -join "`r`n"
        }
        else {
            $global:clientRemoteHostIP = "No valid IP addresses found."
        }
    }
    else {
        $global:clientRemoteHostIP = "Unable to locate the RemoteHostIP element in the XML file."
    }

    $ITfilePath = "$DefI\Config\Config.xml"
    try {
        [xml]$xml = Get-Content $ITfilePath
        $ITServer = $xml.jDummyConfig.ServerHost
        if ($ITServer -eq "" -or $ITServer -eq "localhost") {
            $ITServer = "N/A"
        }

        try {
            $dnsResult = Resolve-DnsName $ITServer
            $global:ITServerIPs = ($dnsResult.IPAddress | Where-Object {$_ -notmatch "^(127\.0)"} ) -join "`r`n"
        }
        catch {
            $ITServerIPs = "Error during DNS lookup"
        }

    }
    catch {
        $ITServer = "Error reading file"
        $ITServerIPs = "Error reading file"
    }  

}

Function AIP {
    $filePath = "C:\Program Files (x86)\BCD\Enterprise\CoService\vinfo.json"
    $fileContent = Get-Content -Path $filePath
    $jsonContent = ConvertFrom-Json -InputObject $fileContent
    $BCver = $jsonContent.version.Split('-')[0]
    if ($BCver -eq "1.8") {
        $global:identity = "BC 1.8"
    }
    elseif ($BCver -eq "1.5") {
        $global:identity = "BC 1.5"
    }    
    elseif ($BCver -eq "1.2") {
        $global:identity = "BC 1.2"
    }
    else {"BC UKN"}

    $HIPfilePath = "C:\Program Files (x86)\BCD\Enterprise\Config\Config.xml"

    try {
        $xmlDocument = [xml](Get-Content -Path $HIPfilePath)

        $clientIP = $xmlDocument.CommunicationsConfig.IPCommsLink | Where-Object { $_.CommsLinkID -eq 'Client' } | Select-Object -ExpandProperty RemoteHost

        $serverIPs = $xmlDocument.CommunicationsConfig.IPCommsLinkListener | Where-Object { $_.CommsLinkID -eq 'Server' } | Select-Object -ExpandProperty RemoteHostIP | Select-Object -ExpandProperty RemoteHost

        if ($clientIP -notmatch "^(192\.168|127\.0)") {
            $global:clientRemoteHostIP = $clientIP
        }
        else {
            $global:clientRemoteHostIP = "Filtered out"
        }
        
        $filteredServerIPs = $serverIPs | Where-Object { $_ -notmatch "^(192\.168|127\.0)" }

        if ($filteredServerIPs) {
            $global:serverRemoteHostIP = $filteredServerIPs -join "`r`n"
        }
        else {
            $global:serverRemoteHostIP = "Filtered out"
        }
    }
    catch {
        $global:clientRemoteHostIP = "Error reading file"
        $global:serverRemoteHostIP = "Error reading file"
    }

    $ITfilePath = "C:\Program Files (x86)\BCD\Enterprise\Config\Config.xml"
    try {
        [xml]$xml = Get-Content $ITfilePath
        $ITServer = $xml.jDummyConfig.ServerHost
        if ($ITServer -eq "" -or $ITServer -eq "localhost") {
            $ITServer = "N/A"
        }

        try {
            $dnsResult = Resolve-DnsName $ITServer
            $global:ITServerIPs = ($dnsResult.IPAddress | Where-Object {$_ -notmatch "^(127\.0)"} ) -join "`r`n"
        }
        catch {
            $ITServerIPs = "Error during DNS lookup"
        }

    }
    catch {
        $ITServer = "Error reading file"
        $ITServerIPs = "Error reading file"
    }  



}

Function EIP {
    $global:identity = "Elephant"
    $global:ITServerIPs = "N/A"

    $HIPfilePath = "C:\Program Files (x86)\BCD\TIP\config\IPConfig.xml"

    $xmlDocument = New-Object -TypeName System.Xml.XmlDocument
    $xmlDocument.Load($HIPfilePath)

    $xPath = "//IPCommsLink/@RemoteHost | //RemoteHostIP/@RemoteHost"

    $global:remoteHostIP = Select-Xml -Xml $xmlDocument -XPath $xPath | ForEach-Object {
        $_.Node.Value
    } | Where-Object { $_ -notmatch "^(192\.168|127\.0)" } | Select-Object -Unique

    $global:clientRemoteHostIP = $global:remoteHostIP | Where-Object { $_ -ne "" }
    $global:serverRemoteHostIP = "Elephant is Client only"
}


Function HIP {
    $global:identity = "Helicopter"
    $global:ITServerIPs = "N/A"
    $hyosungComXmlPath = "C:\Helicopter\BCD\Config\Application\Communication.xml"

    [xml]$xmlDocument = Get-Content $hyosungComXmlPath

    $namespace = @{nh = 'http://www.nh.com/Config' }
    $xPath = "//nh:XmlParam[@Key='RemoteIP']/@Value"

    $global:clientRemoteHostIP = (Select-Xml -Xml $xmlDocument -XPath $xPath -Namespace $namespace).Node.Value
    $global:serverRemoteHostIP = "HYO is Client only"
}
try {
    $xmlDocument = [xml](Get-Content -Path $HIPfilePath)

    $xPathClient = "//IPCommsLink[@CommsLinkID='Client']/@RemoteHost"
    $xPathServer = "//IPCommsLinkListener[@CommsLinkID='Server']/RemoteHostIP/@RemoteHost"

    $clientRemoteHostIP = (Select-Xml -Xml $xmlDocument -XPath $xPathClient).Node.Value
                    
    $serverRemoteHostIP = Select-Xml -Xml $xmlDocument -XPath $xPathServer | ForEach-Object {
        $ip = $_.Node.Value
        if ($ip -notmatch "^(192\.168|127\.0)") {
            $ip
        }
    }
                    
    if ($clientRemoteHostIP -and $clientRemoteHostIP -notmatch "^(192\.168|127\.0)") {
        $global:clientRemoteHostIP = $clientRemoteHostIP -join "`r`n"
        $global:serverRemoteHostIP = $serverRemoteHostIP -join "`r`n"
    }
}
catch {
    $global:clientRemoteHostIP = "Error reading file"
    $global:serverRemoteHostIP = "Error reading file"
}

Function DIP {
    $global:identity = "Detached"
    $global:ITServerIPs = "N/A"
    $comTCPIPcfgPath = "C:\Detached\Configulator\Config\ComIP.cfg"
    if (Test-Path -Path $comTCPIPcfgPath) {

        $settings = New-Object System.Xml.XmlReaderSettings
        $settings.DtdProcessing = [System.Xml.DtdProcessing]::Ignore

        $reader = [System.Xml.XmlReader]::Create($comTCPIPcfgPath, $settings)

        $xmlDocument = New-Object -TypeName System.Xml.XmlDocument
        $xmlDocument.Load($reader)

        $reader.Close()

        $xPath = "//PARAM[@NAME='HOSTNAME']"

        $global:clientRemoteHostIP = (Select-Xml -Xml $xmlDocument -XPath $xPath).Node.InnerText
        $global:serverRemoteHostIP = "Detached is Client only"
    }
}

Function Global {
    try {
        $dnsServers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses | Select-Object -Unique
        if (!$dnsServers) {
            throw "DNS cannot be found. Please double-check to make sure the DNS addresses are present"
        }
    }
    catch {
        try {
            $dnsServers = (Get-WmiObject -Class Win32_NetworkAdapterConfig | Where-Object { $_.DNSServerSearchOrder }).DNSServerSearchOrder | Select-Object -Unique
            if (!$dnsServers) {
                throw "DNS cannot be found using either method. Please double-check to make sure the DNS addresses are present"
            }
        }
        catch {
            Write-Host "An error occurred while trying to find DNS servers: $_"
        }
    }
                        
    if ($dnsServers) {
        $global:dnsServers = $dnsServers -join "`r`n"
    }
    else {
        $global:dnsServers = "DNS cannot be found. Please double-check to make sure the DNS addresses are present"
    }

    try {
        $global:macAddress = Get-NetAdapter -Physical | Select-Object -ExpandProperty MacAddress -First 1
    }
    catch {
        try {
            $global:macAddress = (Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapter WHERE NetConnectionStatus = 2" | Select-Object -ExpandProperty MACAddress -First 1)
            if (!$global:macAddress) {
                throw "No MAC Address could be found."
            }
        }
        catch {
            Write-Host "An error occurred while trying to find MAC address: $_"
        }
    }

    if (Test-Path "C:\PIP\PIPParameters.xml") {
        try {
            [xml]$xml = Get-Content "C:\PIP\PIPParameters.xml"
            $global:PIP = $xml.LocalParameters.serverList.server.hostname
            if ($global:PIP -eq "" -or $global:PIP -eq "localhost") {
                $global:PIP = "N/A"
            }
        }
        catch {
            $global:PIP = "Error reading file"
        }  
    } else {$global:PIP = "N/A"}
}


Function GatherInfo {

    #SOFTWARE IDENTITY
    #Detached (Version 1)
    if (Test-Path -Path "C:\Detached\Configulator\Config\ComIP.cfg") {
        Global
        DIP
    }
    #Detached (Version 2)
    elseif (Test-Path -Path "C:\Detached") {
        Global
        DIP
    }
    #Helicopter (Version 1)
    elseif (Test-Path -Path "C:\Helicopter\BCD\Config\Application\Communication.xml") {
        Global
        HIP
    }
    #Helicopter (Version 2)
    elseif (Test-Path -Path "C:\Helicopter") {
        Global
        HIP
    }
    #BC (Version 1)
    elseif (Test-Path -Path "C:\Program Files (x86)\BCD\Enterprise\Config\Config.xml") {
        Global
        AIP
    }
    #BC (Version 2)
    elseif (Test-Path -Path "C:\inject\BC.ADD") {
        Global
        AIP
    }
    #ITM (Version 1)
    elseif (Test-Path -Path "C:\Program Files*\jDummy\") {
        Global
        IIP
    }
    #ITM (Version 2)
    elseif (Test-Path -Path "C:\inject\Apples.add") {
        Global
        IIP
    }
    #Elephant
    elseif (Test-Path -Path "C:\inject\ElephantAppl.add") {
        Global
        EIP
    }
    #Catch All Left 
    else {
        $global:identity = "Unable to Identify Software"
    }

}

GatherInfo

# $identity,$CompName,$clientRemoteHostIP,$serverRemoteHostIP,$dnsServers,$macAddress,$PIP,$ITServerIPs