FROM ansible/ubuntu14.04-ansible:stable
MAINTAINER twneale@gmail.com

ENV DEBIAN_FRONTEND noninteractive
ENV CORENLP_BROKER_HOST broker
ENV CLASSPATH /usr/local/share/java
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/share/java

# Add playbooks to the Docker image
ADD ansible /ansible/
WORKDIR /ansible

# Run Ansible to configure the Docker image
RUN ansible-playbook site.yml --connection local
