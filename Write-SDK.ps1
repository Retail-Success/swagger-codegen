param(
    [Parameter(Mandatory)] [String] $SwaggerUrl,
    [Parameter(Mandatory)] [System.IO.FileInfo] $SDKClientPath,
    [Parameter(Mandatory)] [String] $DomainOwner,
    [Parameter(Mandatory)] [String] $ServiceName,
    [Parameter(Mandatory)] [String[]] $Scopes,
    [String] $ModelPackage,
    [String] $ApiPackage,
    [Int] $PackageMajorVersion,
    [Int] $PackageMinorVersion,
    [String] $IdentityModelVersion ,
    [String] $NitoAsyncExCoordinationVersion,
    [String] $RefitVersion,
    [String] $RefitHttpClientFactoryVersion,
    [String] $RetailSuccessAuthenticationTokensVersion,
    [String] $RetailSuccessSDKCoreVersion
)

#because the default parameters don't want to work when called by another scrips...
if($null -eq $ModelPackage)
{
    $ModelPackage = "Models"
}

if($null -eq $ApiPackage)
{
    $ApiPackage = "Api"
}

if($null -eq $PackageMajorVersion)
{
    $PackageMajorVersion = 1
}

if($null -eq $PackageMinorVersion)
{
    $PackageMinorVersion = 0
}

if($null -eq $IdentityModelVersion)
{
    $IdentityModelVersion = "3.10.10"
}

if($null -eq $NitoAsyncExCoordinationVersion)
{
    $NitoAsyncExCoordinationVersion = "5.0.0"
}

if($null -eq $RefitVersion)
{
    $RefitVersion = "4.7.9"
}

if($null -eq $RefitHttpClientFactoryVersion)
{
    $RefitHttpClientFactoryVersion = "4.7.9"
}

if($null -eq $RetailSuccessAuthenticationTokensVersion)
{
    $RetailSuccessAuthenticationTokensVersion = "1.0.1"
}

if($null -eq $RetailSuccessSDKCoreVersion)
{
    $RetailSuccessSDKCoreVersion = "1.0.0"
}

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
if(-Not (Test-Path -Path $SDKClientPath))
{
    mkdir $SDKClientPath
}
Clear-Content $SDKClientPath
Move-Item -Path $outFolder -Destination $SDKClientPath