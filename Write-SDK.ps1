param(
    [Parameter(Mandatory=$true)][String]$SwaggerUrl,
    [Parameter(Mandatory=$true)][System.IO.FileInfo]$SDKClientPath,
    [Parameter(Mandatory=$true)][String]$DomainOwner,
    [Parameter(Mandatory=$true)][String]$ServiceName,
    [Parameter(Mandatory=$true)][String[]]$Scopes,
    [parameter(Mandatory=$false)][String]$ModelPackage="Models",
    [parameter(Mandatory=$false)][String]$ApiPackage="Api",
    [parameter(Mandatory=$false)][Int]$PackageMajorVersion=1,
    [parameter(Mandatory=$false)][Int]$PackageMinorVersion=0,
    [parameter(Mandatory=$false)][String]$IdentityModelVersion="3.10.10",
    [parameter(Mandatory=$false)][String]$NitoAsyncExCoordinationVersion="5.0.0",
    [parameter(Mandatory=$false)][String]$RefitVersion="4.7.9",
    [parameter(Mandatory=$false)][String]$RefitHttpClientFactoryVersion="4.7.9",
    [parameter(Mandatory=$false)][String]$RetailSuccessAuthenticationTokensVersion="1.0.1",
    [parameter(Mandatory=$false)][String]$RetailSuccessSDKCoreVersion="1.0.0"
)
docker pull retailsuccess/swagger-codegen

#location for configuration files to mount inside the container
$configFolder=Join-Path -Path $pwd.Path -ChildPath ".codegen\config"
$charpConfigPath=Join-Path -Path $configFolder -ChildPath "config.csharp.json"

if(-Not (Test-Path $configFolder))
{
    mkdir $configFolder
}


#Create config values for rsCsharp lang if not already there
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

$Options | ConvertTo-Json | Out-File $charpConfigPath

$swaggerDocPath=Join-Path -Path $configFolder -ChildPath "swagger.json"

Invoke-WebRequest $SwaggerUrl -OutFile $swaggerDocPath

docker run `
    --rm `
    -v ${configFolder}:/opt/swagger-codegen/config `
    -v ${SDKClientPath}:/opt/swagger-codegen/client `
    retailsuccess/swagger-codegen generate `
        -i /opt/swagger-codegen/config/swagger.json `
        -l  rsCsharp `
        -c /opt/swagger-codegen/config/config.csharp.json `
        -o /opt/swagger-codegen/client/csharp `
        --additional-properties excludeTests=true