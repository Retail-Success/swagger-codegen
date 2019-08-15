Function Write-SDK {

<#
    .SYNOPSIS
    Write an SDK client
    .DESCRIPTION
    Writes a csharp SDK client to the specified directory using the docker image retailsuccess/swagger-codegen
    .EXAMPLE
    Generate-SDK -SwaggerUrl "localhost:80/swagger/v1/swagger.json" -DomainOwner "Bless" -ServiceName "ViewStores" -Scopes {"viewstores", "viewproducts"} -SDKClientPath .\client

#>

param(
    [String] $SwaggerUrl,
    [System.IO.FileInfo] $SDKClientPath,
    [String] $DomainOwner,
    [String] $ServiceName,
    [String[]] $Scopes,
    [String] $ModelPackage = "Models",
    [String] $ApiPackage = "Api",
    [Int] $PackageMajorVersion = 1,
    [Int] $PackageMinorVersion = 0,
    [String] $IdentityModelVersion = "3.10.10",
    [String] $NitoAsyncExCoordinationVersion = "5.0.0",
    [String] $RefitVersion = "4.7.9",
    [String] $RefitHttpClientFactoryVersion = "4.7.9",
    [String] $RetailSuccessAuthenticationTokensVersion = "1.0.1",
    [String] $RetailSuccessSDKCoreVersion = "1.0.0"
)

docker pull retailsuccess/swagger-codegen

#Config values
$Options=@{ }
$Options.Add('domainOwner',$DomainOwner)
$Options.Add('serviceName', $ServiceName)
$Options.Add('modelPackage', $ModelPackage)
$Options.Add('apiPackage', $ApiPackage)
$Options.Add('packageMajorVersion', $PackageMajorVersion)
$Options.Add('packageMinorVersion', $PackageMinorVersion)
$Options.Add('apiScopesCommaSeperated', ($Scopes -join ","))
$Options.Add('packageVersionIdentityModel', $IdentityModelVersion)
$Options.Add('packageVersionNitoAsyncExCoordination', $NitoAsyncExCoordinationVersion)
$Options.Add('packageVersionRefit', $RefitVersion)
$Options.Add('packageVersionRefitHttpClientFactory', $RefitHttpClientFactoryVersion)
$Options.Add('packageVersionRetailSuccessAuthenticationTokens', $RetailSuccessAuthenticationTokensVersion)
$Options.Add('packageVersionRetailSuccessSDKCore', $RetailSuccessSDKCoreVersion)

#create a temp folder
$tempFolder=Join-Path -Path $env:Temp -ChildPath $ServiceName+".SDKBuilder"

#location for configuration files to mount inside the container
$configFolder=Join-Path -Path $tempFolder -ChildPath "config"
$configPath=Join-Path -Path $configFolder -ChildPath "config.json"

#location for codegen to place output files
$outFolder=Join-Path -Path $tempFolder -ChildPath "out"

mkdir $configFolder -Force
mkdir $outFolder -Force

$Options | ConvertTo-Json | Out-File $configPath

docker run `
    --rm `
    -v ${configFolder}:/opt/swagger-codegen/config `
    -v ${outFolder}:/opt/swagger-codegen/out `
    retailsuccess/swagger-codegen generate `
        -i $SwaggerUrl `
        -l rsCsharp `
        -c /opt/swagger-codegen/config/config.json `
        -o /opt/swagger-codegen/out `
        --additional-properties excludeTests=true

#clear out current contents of client folder, then copy new client files over
Get-ChildItem $SDKClientPath -Recurse | Remove-Item
Move-Item -Path $outFolder -Destination $SDKClientPath

}

Export-ModuleMember -Function Write-SDK
