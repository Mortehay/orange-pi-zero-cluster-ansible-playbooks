# 🎮 Orange Pi Zero 3 Minecraft & Django Cluster

This repository contains an automated suite of **Ansible** playbooks and shell scripts to transform your **Orange Pi Zero 3 (4GB)** boards into a high-performance **Docker Swarm Cluster**. The primary goal is to host a **PaperMC Minecraft Server** and a **MariaDB Database** for Django applications.

---

## 📂 Project Structure

* `run_cluster.sh`: The master execution script that loads environment variables and runs playbooks.
* `inventory.ini`: Defines your master and worker nodes.
* `.env`: (**User Created**) Stores sensitive credentials like `SUDO_PASS`.
* `configure-hosts.yml`: System-level optimizations (CPU speed, Hostnames, and Avahi).
* `docker.yml`: Docker engine installation with Armbian-specific kernel tweaks for cgroups.
* `docker-swarm.yml`: Orchestration logic to link nodes into a single swarm cluster.
* `deploy-minecraft.yml`: Docker Stack definition optimized for 4GB RAM hardware.

---

## 🛠 1. Initial Setup

### Node Preparation
Before running Ansible, the nodes must be able to communicate:
1.  **OS Installation**: Ensure both boards are running a fresh Armbian (Debian/Ubuntu-based) image.
2.  **SSH Access**: You must be able to SSH from the Master node to the Worker node without a password. Share your public key from the Master:
    ```bash
    ssh-copy-id markunn@10.42.0.239
    ```

### Ansible Installation
Ansible must be installed on your **Master Node** (the board acting as the control node).
1.  **Update Repository**: 
    ```bash
    sudo apt update
    ```
2.  **Install Ansible**:
    ```bash
    sudo apt install ansible -y
    ```
3.  **Verify Setup**: Run `ansible --version` to confirm installation.

### Environment & Inventory
1.  **Create .env**: Create a file named `.env` in the root folder to store your system password:
    ```bash
    cat <<EOF > .env
    SUDO_PASS=your_actual_system_password
    EOF
    ```
2.  **Configure inventory.ini**: Ensure your IPs are correct. For your setup, use `localhost` for the Master and `10.42.0.239` for the Worker.

---

## 🚀 2. Running the Cluster Setup

Execute the full stack using the master script. This script automatically loads your `.env` variables and passes the `sudo` password to the Ansible playbooks.

```bash
chmod +x run_cluster.sh
./run_cluster.sh

What happens during execution:

Hardware Tuning: Sets CPU max speed to 1.5GHz (1512000) to ensure maximum single-threaded performance.

Kernel Fixes: Switches to iptables-legacy and disables unified_cgroup_hierarchy for Armbian kernel compatibility.

Swarm Sync: The Master initializes the swarm and the worker node joins automatically.

Minecraft Deployment: Launches a PaperMC server with 3GB RAM allocated (tuned for 4GB hardware).

🏗 3. Maintenance & Management
Check Cluster Health
To verify that your worker is active and connected to the manager:

Bash

docker node ls
Monitoring Minecraft
View the live console logs for the Minecraft service:

Bash

docker service logs -f mc_mc
Updating Services
To update Minecraft versions or configurations, run the deploy command again to trigger a rolling update:

Bash

docker stack deploy -c deploy-minecraft.yml mc
🔄 4. Scaling for Django
Database & Fake Data
If you are developing Django applications on this cluster:

Deploy MariaDB: Use your mariadb-stack.yml to launch the database service.

Django Seeding: To populate your development environment with fake data, utilize django-autofixture or django-seed.

Note: Ensure your DATABASE_URL in Django points to the Master IP on port 4000 (MaxScale).

Bash

# Example: Running seeder from within the app container
docker exec -it <django_container_id> python manage.py seed app_name --number=50
⚠️ Troubleshooting
"Missing Sudo Password": Ensure your .env file exists and contains the correct SUDO_PASS.

"No Hosts Matched": Check that your inventory.ini uses the group name [opies].

Minecraft Lag: Ensure configure-hosts.yml ran successfully. Check if your CPU frequency is locked at 1.5GHz using cpufreq-info.


Would you like me to help you create a specific `mariadb-stack.yml` file to complement this Django setup?