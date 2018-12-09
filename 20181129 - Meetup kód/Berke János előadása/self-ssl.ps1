<#
    ssl generálás (SAN!!!)
#>
New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\my -dnsname WIN-NKUM2OBGQ3D, SSRS, SSRS.domain.local
$pwd=ConvertTo-SecureString "password1" -asplainText -force
$file="C:\temp\cert1.pfx"

<#
    SSL import
#>
Export-PFXCertificate -cert cert:\LocalMachine\My\<Thumbprint produced during first command> -file $file -Password $pwd
Import-PfxCertificate -FilePath $file cert:\LocalMachine\root -Password $pwd

<#
    ssl beállítás

    1. Config manager, de nincs SAN
    2. rsreportserver.config
        - <Add Key="SecureConnectionLevel" Value="1"/>

    SAN
    1. netsh http show urlacl
    2.rsreportserver.config: két helyen is kell --> ReportServer és Reports virtual dir
                <URL>
					<UrlString>https://ssrs:443</UrlString>
					<AccountSid>S-1-5-80-4050220999-2730734961-1537482082-519850261-379003301</AccountSid>
					<AccountName>NT SERVICE\SQLServerReportingServices</AccountName>
				</URL>
                <URL>
					<UrlString>https://ssrs.domain.local:443</UrlString>
					<AccountSid>S-1-5-80-4050220999-2730734961-1537482082-519850261-379003301</AccountSid>
					<AccountName>NT SERVICE\SQLServerReportingServices</AccountName>
				</URL>
    3. Netsh http add urlacl url=https://ssrs:443/Reports user="NT SERVICE\SQLServerReportingServices" 
    4. Netsh http add urlacl url=https://ssrs.domain.local:443/Reports user="NT SERVICE\SQLServerReportingServices" 
    5. Netsh http add urlacl url=https://ssrs:443/ReportServer user="NT SERVICE\SQLServerReportingServices" 
    6. Netsh http add urlacl url=https://ssrs.domain.local:443/ReportServer user="NT SERVICE\SQLServerReportingServices" 
    7. SSRS svc újraindítás

    SSL csere
    1. új cert
    2. delete sslcert ipport=0.0.0.0:443
    3. delete sslcert ipport=[::]:443
    4. netsh httpadd sslcert ipport=0.0.0.0:443 certhash=24EDC385B88B2DB079B47F35479EC1CD2CCF4162 appid={1d40ebc7-1983-4ac5-82aa-1e17a7ae9a0e}
    5. netsh httpadd sslcert ipport=[::]:443 certhash=24EDC385B88B2DB079B47F35479EC1CD2CCF4162 appid={1d40ebc7-1983-4ac5-82aa-1e17a7ae9a0e}

#>
