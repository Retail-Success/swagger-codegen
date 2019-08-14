param(
    [String] $Version
)

mvn -DskipTests package
cd rsCsharpClientGenerator
mvn -DskipTests package
cd ..

docker build -t retailsuccess/swagger-codegen:latest -t retailsuccess/swagger-codegen:$Version .

#docker build -t retailsuccess/swagger-generator-api:latest -t retailsuccess/swagger-generator-api:$Version ./modules/swagger-generator

docker push retailsuccess/swagger-codegen:latest

docker push retailsuccess/swagger-codegen:$Version

#docker push retailsuccess/swagger-generator-api:latest

#docker push retailsuccess/swagger-generator-api:$Version