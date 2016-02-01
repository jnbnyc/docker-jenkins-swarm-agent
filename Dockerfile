FROM jnbnyc/buildtools

#  Install supporting software
USER root
RUN install-apts git apt-transport-https ca-certificates curl lxc iptables

#  For DIND Install Docker from Docker Inc. repositories.
# RUN curl -sSL https://get.docker.com/ubuntu/ | sh

#  Set up jenkins user
ENV JENKINS_HOME /var/jenkins_home
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins
RUN usermod -a -G users jenkins

#  Install Swarm
ENV SWARM_VERSION 1.24

RUN curl http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/"$SWARM_VERSION"/swarm-client-"$SWARM_VERSION"-jar-with-dependencies.jar -o "$JENKINS_HOME"/swarm-client-"$SWARM_VERSION"-jar-with-dependencies.jar

RUN chown -R jenkins:jenkins "$JENKINS_HOME"
RUN chmod 664 "$JENKINS_HOME"/swarm-client-"$SWARM_VERSION"-jar-with-dependencies.jar

# Kick off swarm
USER jenkins

ADD swarm.sh /usr/local/bin/swarm.sh
ENTRYPOINT ["/usr/local/bin/swarm.sh"]
