FROM ubuntu:xenial
SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y curl apt-transport-https ca-certificates

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt update && apt install -y openjdk-8-jdk wget git gnupg-agent software-properties-common docker-compose docker
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install nodejs yarn


# Install tailwind
RUN yarn global add tailwind
# Install env-cmd
RUN yarn global add env-cmd

# Install Jenkins slave in swarm mode
ENV JENKINS_SWARM_VERSION 3.26
ENV HOME /home/jenkins-slave

# # install netstat to allow connection health check with
# # netstat -tan | grep ESTABLISHED
RUN apt-get update && apt-get install -y net-tools && rm -rf /var/lib/apt/lists/*

RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave
RUN usermod -a -G docker jenkins-slave
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar && chmod 755 /usr/share/jenkins

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

USER jenkins-slave
VOLUME /home/jenkins-slave

ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/jenkins-slave.sh"]