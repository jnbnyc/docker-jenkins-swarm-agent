#!/bin/bash
set -e

# checks and defaults

SWARM_JAR="$JENKINS_HOME"/swarm-client-"$SWARM_VERSION"-jar-with-dependencies.jar

[ -z "$SWARM_MASTER" ] && echo "SWARM_MASTER was not specified, enabling autodiscovery"
                   
[ -z "$SWARM_NAME" ] && SWARM_NAME="$HOSTNAME"
[ -z "$SWARM_DESCRIPTION" ] && SWARM_DESCRIPTION="Swarm version: $SWARM_VERSION - Jenkins slave for docker jobs"

[ -z "$SWARM_EXECUTORS" ] && SWARM_EXECUTORS="1"
[ -z "$SWARM_MODE" ] && SWARM_MODE="exclusive"
[ -z "$SWARM_LABELS" ] && SWARM_LABELS="docker"

[ -z "$SWARM_RETRY" ] && SWARM_RETRY="10"
[ -z "$SWARM_CREDFILE" ] && SWARM_CREDFILE="/etc/jenkmaster-creds/jenkmaster-creds"

[ -z "$DOCKER_CONFIGFILE" ] && DOCKER_CONFIGFILE="/etc/docker-config/.dockercfg"

# links

[ -f $DOCKER_CONFIGFILE ] && ln -s "$DOCKER_CONFIGFILE" "$JENKINS_HOME"/.dockercfg

# entrypoint

exec java -jar "$SWARM_JAR" \
          -fsroot "$JENKINS_HOME" \
          -noRetryAfterConnected \
          -showHostName \
          $([ -n "$SWARM_MASTER" ] && echo '-master "$SWARM_MASTER"' )\
          -name "$SWARM_NAME" \
          -description "$SWARM_DESCRIPTION" \
          -executors "$SWARM_EXECUTORS" \
          -mode "$SWARM_MODE" \
          -labels "$SWARM_LABELS" \
          -retry "$SWARM_RETRY" \
          $([ -f $SWARM_CREDFILE ] && echo "-username $(head -n1 $SWARM_CREDFILE) \
                                            -password $(tail -n1 $SWARM_CREDFILE)") \
          "$@"