param(
    [String] $Version
)


mvn -DskipTests package
cd rsCsharpClientGenerator
mvn -DskipTests package
cd ..


docker build -t retailsuccess/swagger-codegen:latest .

docker tag retailsuccess/swagger-codegen:latest retailsuccess/swagger-codegen:$Version

docker push retailsuccess/swagger-codegen:latest

docker push retailsuccess/swagger-codegen:$Version