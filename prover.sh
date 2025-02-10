echo "   #######   "
echo "  ##     ##  "
echo " ##          "
echo " ##   #####  "
echo " ##     ##   "
echo "  ##     ##  "
echo "   #######   "

# ========================================
#  Made BY GOWTHERNODE
#  Join My Channel https://t.me/airdropforgeindonesia
# ========================================

#!/bin/bash

set -e

echo "Installing required packages..."
sudo apt install -y curl supervisor nano

# Prompt user for EVM-based reward address
echo "Enter your EVM-based reward address (0x...):"
read REWARD_ADDRESS

# Download and run setup script with reward address
curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_prover.sh -o ~/setup_prover.sh
chmod +x ~/setup_prover.sh
bash ~/setup_prover.sh "$REWARD_ADDRESS"

# rename prover 1
mv cysic-prover cysic-prover1

# Download params
echo "Downloading params..."
mkdir -p ~/.scroll_prover/params
curl -L --retry 999 -C - circuit-release.s3.us-west-2.amazonaws.com/setup/params20 -o ~/.scroll_prover/params/params20
curl -L --retry 999 -C - circuit-release.s3.us-west-2.amazonaws.com/setup/params24 -o ~/.scroll_prover/params/params24
curl -L --retry 999 -C - circuit-release.s3.us-west-2.amazonaws.com/setup/params25 -o ~/.scroll_prover/params/params25

# Prompt user for EVM-based reward address
echo "Enter your EVM-based reward address-2 (0x...):"
read REWARD_ADDRESS2

# Setup Prover for Address2
echo "Setting up prover for Address-2"
    curl -L github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_prover.sh -o ~/setup_prover.sh
    chmod +x ~/setup_prover.sh
    bash ~/setup_prover.sh "$REWARD_ADDRESS2"
    
# rename prover 1
mv cysic-prover cysic-prover2

# Configure Supervisor
echo "Configuring Supervisor..."
cat <<EOF | sudo tee /etc/supervisord.conf
[unix_http_server]
file=/tmp/supervisor.sock

[supervisord]
logfile=/tmp/supervisord.log
logfile_maxbytes=50MB
logfile_backups=10
loglevel=info
pidfile=/tmp/supervisord.pid
nodaemon=false
silent=false
minfds=1024
minprocs=200
strip_ansi=true

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock

[program:cysic-prover]
command=/home/ubuntu/cysic-prover1/prover
numprocs=1
directory=/home/ubuntu/cysic-prover1
priority=999
autostart=true
redirect_stderr=true
stdout_logfile=/home/ubuntu/cysic-prover1/cysic-prover.log
stdout_logfile_maxbytes=1GB
stdout_logfile_backups=1
environment=LD_LIBRARY_PATH="/home/ubuntu/cysic-prover1",CHAIN_ID="534352"

[program:cysic-prover-2]
command=bash -c "sleep 2000 && /home/ubuntu/cysic-prover2/prover"
numprocs=1
directory=/home/ubuntu/cysic-prover2
priority=999
autostart=true
redirect_stderr=true
stdout_logfile=/home/ubuntu/cysic-prover2/cysic-prover.log
stdout_logfile_maxbytes=1GB
stdout_logfile_backups=1
environment=LD_LIBRARY_PATH="/home/ubuntu/cysic-prover2",CHAIN_ID="534352"
EOF

# Start Supervisor
echo "Starting Supervisor..."
supervisord -c supervisord.conf

echo "Installation complete! Use 'supervisorctl tail -f cysic-prover' or 'supervisorctl tail -f cysic-prover-2' to check logs."
