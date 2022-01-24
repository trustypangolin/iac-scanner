FROM buildpack-deps:latest

# Update and allow for apt over HTTPS
RUN apt-get update && \
  apt-get install -y apt-utils
RUN apt-get install -y apt-transport-https

# Install python3
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

# Install Ruby
RUN apt-get -y install ruby-full

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH /root/.cargo/bin:$PATH

# Install Go
RUN apt-get -y install golang

# Install CFN Linter and checkov
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Install CFN_Nag
COPY Gemfile ./
RUN gem install bundler
RUN bundle install

# Install CFN_Guard
RUN cargo install cfn-guard

# Install TF Scanner
RUN Arch="$(uname -m)"; \
    case "$Arch" in \
        aarch64) curl -L https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-arm64 --output /usr/local/bin/tfsec ;; \
        arm64) curl -L https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-arm64 --output /usr/local/bin/tfsec ;; \
        x86_64) curl -L https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64 --output /usr/local/bin/tfsec ;; \
    esac;

RUN chmod a+x /usr/local/bin/tfsec
RUN apt-get -y clean

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Default Sane Environment Variables
ENV scanfolder="/src"
ENV CFN_NAG_OPT="--ignore-fatal"
ENV CFN_LINT_FIND="-name '*.yml' -o -name '*.yaml'"
ENV CFN_LINT_OPT="-b"
ENV CFN_NAG_OPT="--ignore-fatal"
ENV CHECKOV_OPT="--skip-check CKV_SECRET_6 --skip-suppressions --quiet"
ENV INPUT_SCANNER="all"

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
