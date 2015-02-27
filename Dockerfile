FROM ansible/ubuntu14.04-ansible:stable
MAINTAINER twneale@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Add playbooks to the Docker image
ADD ansible /ansible/
WORKDIR /ansible

# Run Ansible to configure the Docker image
# RUN ansible-playbook site.yml --connection local

# EXPOSE 5559
CMD "/bin/bash"
# CMD "/usr/lib/supervisord -c /etc/supervisor/supervisord.conf"