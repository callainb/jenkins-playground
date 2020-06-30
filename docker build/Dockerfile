FROM centos:8

RUN yum -y install openssh-server

RUN useradd remusr && \
  echo "remusr:1234" | chpasswd && \
  mkdir /home/remusr/.ssh && \
  chmod 700 /home/remusr/.ssh

# Add existing public key to allow for ssh access
COPY remusr.pub /home/remusr/.ssh/authorized_keys

RUN chown remusr:remusr -R /home/remusr/.ssh && \
  chmod 600 /home/remusr/.ssh/authorized_keys

#It's a script to create the host keys. There's a systemd service that goes with it, sshd-keygen@.service.
# The service checks if a particular host key doesn't exist, and runs the script which just calls ssh-keygen to create them
#The SSH server itself has a key that it uses to identify itself to clients. This is to prevent man-in-the-middle attacks, etc. Also why you'll see something like
#
#The authenticity of host '[foo.example.com]:22 ([10.0.2.15]:22)' can't be established.
#ECDSA key fingerprint is SHA256:QOCUzNedwfepPHZ8JOn7xfGc1zQ8MmIohNCAE93jMEQ.
#Are you sure you want to continue connecting (yes/no)?
#The first time you connect to a remote host using ssh/scp/sftp
#
#Actual files on the server for these keys should be under /etc/ssh -

#ssh_host_dsa_key
#ssh_host_dsa_key.pub
#ssh_host_ecdsa_key
#ssh_host_ecdsa_key.pub
#ssh_host_ed25519_key
#ssh_host_ed25519_key.pub
#ssh_host_rsa_key
#ssh_host_rsa_key.pub

#RUN /usr/libexec/openssh/sshd-keygen -A
RUN ssh-keygen -A

EXPOSE 22

# This prevents non-root logins...
# System is booting up. Unprivileged users are not permitted to log in yet. Please come back later. For technical details, see pam_nologin(8).
RUN rm -f /var/run/nologin

CMD /usr/sbin/sshd -D
