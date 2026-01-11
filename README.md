# docker-updater-crontab
## TL;DR - Watchtower for poor

⭐ When the VPS provider uses LXC-style virtualization or hardened KVM with “no privileged containers” enforced.
This is common on:
- Contabo
- IONOS
- OVH low-tier VPS
- Some Hetzner CX plans
- Oracle Free Tier
- Any VPS using LXD/LXC under the hood
- Any provider enforcing “rootless-like” restrictions even for rootful Docker
These systems allow Docker, but block containers from controlling Docker.

🎯 What this means for Watchtower
- Watchtower cannot work on this VPS.\
- Not because of your config.\
- Not because of Docker.\
- Not because of permissions.\
- Not because of the image.\
- But because the VPS provider forbids containers from accessing the Docker daemon.\
- This is a hard block.\
  
No amount of:
- user: "0:0"
- cap_add
- privileged: true
- security_opt: unconfined
- apparmor: unconfined
- seccomp: unconfined
…will bypass this.
The kernel simply refuses the connection.

# Multi‑Folder Docker Update Script

A lightweight, cron‑friendly Bash script that updates multiple Docker Compose projects in one pass.  
Designed for VPS environments where tools like Watchtower cannot access the Docker socket.

This script:

- Pulls updated images
- Recreates containers with `docker compose up -d`
- Cleans unused images (`docker image prune -f`)
- Supports multiple project folders
- Accepts folders as arguments **or** reads from a `folders.txt` file
- Logs output cleanly for debugging

---

## ✨ Features

- **Multi‑folder support**  
  Update any number of Docker Compose projects in a single run.

- **Two input modes**  
  - Pass folders directly as arguments  
  - Or maintain a `folders.txt` file with one folder per line

- **Safe update workflow**  
  - Pull new images  
  - Recreate containers  
  - Prune unused images  
  - No volume deletion  
  - No forced restarts of stopped containers

- **Cron‑friendly**  
  Uses absolute paths and produces clean logs.

---

## 📁 Folder Structure
```/home/user/projectdocker/ │ ├── update.sh        
# Main update script └── folders.txt      
# Optional list of project folders
```
## Example `folders.txt`:
```
/home/user/immich
/home/user/nextcloud 
/home/user/traefik 
/home/user/n8n
/home/user/monitoring
```

## 🛠️ Installation

1. Copy `update.sh` into your project directory:
2. Make it executable:
```bash
chmod +x /home/user/projectdocker/update.sh
```
- (Optional) Create folders.txt with one folder per line.

## 🚀 Usage

### A) Run using folders from folders.txt

/home/user/projectdocker/update.sh

### B) Run with folders passed as arguments
```
/home/user/projectdocker/update.sh /opt/stack1 /opt/stack2
```


## 🔧 Script Behavior
For each folder:
1. docker compose pull
   - Pulls updated images
   - Does not start stopped containers
2. docker compose up -d
   - Recreates only changed containers
   - Leaves stopped containers untouched
3. docker image prune -f
   - Removes unused images
   - Equivalent to Watchtower’s `WATCHTOWER_CLEANUP=true` \
  This replicates the safe parts of Watchtower’s behavior without requiring privileged containers.

##⏱️ Cron Automation

To run updates every night at 02:00:
```
crontab -e
```
Add:
```
0 2 * * * /home/user/projectdocker/update.sh >> /home/user/projectdocker/update.log 2>&1
```

This will:
- Update all stacks
- Log output to update.log
- Run unattended

## 🧪 Testing
Run manually:
bash /home/user/projectdocker/update.sh


### Check logs:
cat /home/user/projectdocker/update.log


## 🛡️ Notes
- Script uses absolute paths for cron compatibility.
- Does not remove volumes or networks.
- Does not revive stopped containers.
- Safe to run daily or even hourly.
- Works on VPS providers that block privileged containers.

