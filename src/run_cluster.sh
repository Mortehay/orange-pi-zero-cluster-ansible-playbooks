#!/bin/bash

# 1. Load environment variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "✅ Environment variables loaded from .env"
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

# 2. Define a helper function to run playbooks
run_playbook() {
    echo "🚀 Running: $1..."
    ansible-playbook -i inventory.ini "$1" --extra-vars "ansible_become_password=$SUDO_PASS"
    
    if [ $? -eq 0 ]; then
        echo "✅ $1 completed successfully."
    else
        echo "❌ $1 failed. Stopping sequence."
        exit 1
    fi
}

# --- EXECUTION SEQUENCE ----

# Step A: Optimize hardware
run_playbook "configure-hosts.yml"

# Step B: Install Docker
run_playbook "docker.yml"

# Step C: Initialize Docker Swarm
run_playbook "docker-swarm.yml"

# Step D: Deploy Minecraft Stack
echo "🎮 Deploying Minecraft Server..."
docker stack deploy -c deploy-minecraft.yml mc

# Step E: Deploy MariaDB Stack
echo "🗄️ Deploying MariaDB Database..."
docker stack deploy -c mariadb-stack.yml db

# --- NEW STEP ---
# Step F: Deploy Portainer Monitoring
echo "📊 Setting up Portainer Monitoring..."
# 1. Create a persistent volume for Portainer data on the Master node
docker volume create portainer_data

# 2. Download and deploy the official Swarm stack
# This handles the Portainer Server on Master and Agents on all nodes
curl -L https://downloads.portainer.io/ce-lts/portainer-agent-stack.yml -o portainer-agent-stack.yml
docker stack deploy -c portainer-agent-stack.yml portainer

echo "🌐 Monitoring ready at http://10.42.0.238:9000"