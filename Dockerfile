FROM alpine:latest
# Install needed system packages required by tools
RUN apk update && apk upgrade && apk add --no-cache aha bash coreutils curl drill git go libidn jq openssl procps python3 py3-pip socat xxd
# Define system non-root user
RUN addgroup -S validator && adduser -S validator -G validator -s /bin/bash
## User home folder and location in which all tools will be installed
RUN mkdir -m 755 -p /home/validator
## Location to share data between the container and the host
RUN mkdir -m 755 -p /share
RUN chown validator:validator /share
# Switch as non-root user
USER validator
WORKDIR /home/validator
# Install tools
RUN git clone --depth 1 https://github.com/drwetter/testssl.sh.git /home/validator/testssl
RUN git clone --depth 1 https://github.com/stamparm/identYwaf.git /home/validator/identYwaf
RUN go install github.com/ffuf/ffuf@latest
RUN go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
RUN curl https://github.com/ovh/venom/releases/download/v1.0.1/venom.linux-amd64 -L -o /home/validator/venom
# Set profile
RUN echo "export PATH=$PATH:/home/validator/go/bin:/home/validator" >> /home/validator/.bashrc
RUN echo "alias ll='ls -rtl'" >> /home/validator/.bashrc
# Set execution rights
RUN chmod +x -R /home/validator
# Update tools
RUN /home/validator/go/bin/nuclei -update-templates 
RUN /home/validator/venom update || true
