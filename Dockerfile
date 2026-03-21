FROM almalinux/10-base:latest

# Install Python 3.12 and development dependencies
RUN dnf install -y \
    python3.12 \
    python3.12-pip \
    python3.12-devel \
    gcc \
    gcc-c++ \
    make \
    libpq-devel \
    git \
    openssh-clients \
    && dnf clean all

# Set Python 3.12 as default
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.12 1

# Create dagster user
RUN useradd -m -s /bin/bash dagster

# Set working directory
WORKDIR /opt/dagster

# Install Dagster core and dependencies from the project's requirements
COPY requirements.txt /opt/dagster/requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy Dagster instance config
COPY workspace.yaml /opt/dagster/
COPY dagster.yaml /opt/dagster/

# Copy SSH key
COPY id_rsa /home/dagster/.ssh/id_rsa
RUN chmod 700 /home/dagster/.ssh \
    && chmod 600 /home/dagster/.ssh/id_rsa \
    && chown -R dagster:dagster /home/dagster/.ssh

# Set environment for Dagster home
ENV DAGSTER_HOME=/opt/dagster

# Change ownership
RUN chown -R dagster:dagster /opt/dagster

USER dagster

EXPOSE 3000

CMD ["dagster-webserver", "-h", "0.0.0.0", "-p", "3000"]
