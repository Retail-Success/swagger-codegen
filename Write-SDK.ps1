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

#Config values for rsCsharp lang
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
$tempFolder=Join-Path -Path $env:Temp -ChildPath "SDKBuilder"
Remove-Item $tempFolder

#location for configuration files to mount inside the container
$configFolder=Join-Path -Path $tempFolder -ChildPath "config"
$configPath=Join-Path -Path $configFolder -ChildPath "config.json"

#location for codegen to place output files
$outFolder=Join-Path -Path $tempFolder -ChildPath "out"

mkdir $configFolder -Force
mkdir $outFolder -Force

$swaggerDocPath=Join-Path -Path $configFolder -ChildPath "swagger.json"

$Options | ConvertTo-Json | Out-File $configPath

Invoke-WebRequest $SwaggerUrl -OutFile $swaggerDocPath

docker run `
    --rm `
    -v ${configFolder}:/opt/swagger-codegen/config `
    -v ${outFolder}:/opt/swagger-codegen/out `
    retailsuccess/swagger-codegen generate `
        -i /opt/swagger-codegen/config/swagger.json `
        -l  rsCsharp `
        -c /opt/swagger-codegen/config/config.json `
        -o /opt/swagger-codegen/out/csharp `
        --additional-properties excludeTests=true

#clear out current contents of client folder, then copy new client files over
if((Test-Path -Path $SDKClientPath))
{
    Remove-Item $SDKClientPath
}
Move-Item -Path $outFolder -Destination $SDKClientPath