#!/usr/bin/env bash

set -euo pipefail

# GEN_DIR allows to share the entrypoint between Dockerfile and run-in-docker.sh (backward compatible)
GEN_DIR=${GEN_DIR:-/opt/swagger-codegen}
JAVA_OPTS=${JAVA_OPTS:-"-Xmx1024M -DloggerPath=conf/log4j.properties"}

cli="${GEN_DIR}/modules/swagger-codegen-cli"
codegen="${cli}/target/swagger-codegen-cli.jar"
cmdsrc="${cli}/src/main/java/io/swagger/codegen/cmd"
rsClient="${GEN_DIR}/rsCsharpClientGenerator/target/rsCsharpClientCodegen.jar"

pattern="@Command(name = \"$1\""
if expr "x$1" : 'x[a-z][a-z-]*$' > /dev/null && fgrep -qe "$pattern" "$cmdsrc"/*.java || expr "$1" = 'help' > /dev/null; then
    # If ${GEN_DIR} has been mapped elsewhere from default, and that location has not been built
    if [[ ! -f "${codegen}" ]]; then
        (cd "${GEN_DIR}" && exec mvn -am -pl "modules/swagger-codegen-cli" -Duser.home=$(dirname $MAVEN_CONFIG) package)
    fi
    #exec -am -pl "rsCsharpClientGenerator" -Duser.home=$(dirname $MAVEN_CONFIG) package
    command=$1
    shift
    exec java ${JAVA_OPTS} -cp "${codegen}:${rsClient}" io.swagger.codegen.SwaggerCodegen "${command}" "$@"
else
    exec "$@"
fi
