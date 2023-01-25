# What is this?
- This is a repo for my Terraform config for Oracle Cloud
- This config automatically creates a minecraft server running Purpur server version 1.19.3
- This server is resilient to reboots and crashes, so it should be pretty reliable
- This performs the following steps
  - Spins up a VM in Oracle Cloud's Always Free tier with the following parameters
    - ARM CPU architecture
    - Ubuntu Server 22.04
    - 4 OCPUs (4 vCPUs)
    - 24GB RAM
  - Creates a DNS record for your server in Cloudflare DNS
  - Triggers Ansible to
    - Automate OS patching
    - Install Zabbix agent for monitoring
    - Install and setup Minecraft server
    - Copy rclone config
- At the bottom of this readme there's steps on setting up the backups using Kopia

# Requirements
- Linux machine to run this from (WSL works on Windows)
- Terraform
- Ansible
- [OCI-CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- [Oracle Terraform docs for reference](https://learn.hashicorp.com/collections/terraform/oci-get-started)

# Getting started
- You need to be running from some kind of Linux terminal
- I did this in WSL 2 with Ubuntu, so that works if you need something
- Start by cloning this repo
```
git clone https://github.com/USBAkimbo/terraform-minecraft
cd terraform-minecraft
```
- Initialize Terraform
```
terraform init
```
- Copy the example vars file
```
cp tfvars.example terraform.tfvars
```
- Modify the `terraform.tfvars` file to include your Oracle account variables and Cloudflare variables
- Modify `ansible-config.yml` to include your variables
- My example uses my Ansible Vault strings
- You can do this using
```
ansible-vault encrypt_string yourstringhere

<enter vault password>

!vault |
          $ANSIBLE_VAULT;1.1;AES256
          62343563353836383962376363393931343961316331343564653939303030356638386136666562
          3161653562333736313162623630626538646264643035350a623939623532346462353432316231
          63393762333435613833306136633761323932336539623462353733636335383235653162616562
          6261386236303631310a376536303333643338663136323031613662343038663765656530313061
          6264
```
- You don't have to use vault, so your file could look like this
```
- hosts: all
  roles:
    - patch
    - etc...
  vars:
    email: me@example.com
    dns_name: example.mydomain.com
```
- Create the `ansible-vault-key` file to allow Ansible to run in Terraform config
```
echo "vaultpasswordhere" >> ansible-vault-key
```
- Once this is all done, run the following to start the build
```
terraform apply
```
- Note that this will probably fail for the first time on the Ansible step
- This is because the VM isn't ready just yet
- If it does fail, just re-run the `terraform apply` again
- That should be it! Give it a few minutes and your server should be up
- It may also fail due to capacity issues on Oracle's end
- If this happens, create a cron job to run every 6 hours that does a `terraform apply -auto-approve` to automatically create the VM for you
- I'd also recommend you read through the roles folder and tweak the config to what you want

# Backups
## Before you start
- Before you do this, check if the Kopia and rclone versions are up to date in the `install-minecraft-server.yml` Ansible config file
- I might not keep them up to date, so just double check

## rclone config
- To setup the backups, su to the `minecraft` user
```
root@server$ su minecraft
```
- Then run
```
rm /opt/minecraft/.config/rclone/rclone.conf
```
- This will remove my config
- Then run
```
rclone config
```
- Follow the wizard to connect rclone to your cloud storage provider
- Cool, now you have rclone configured

## Kopia config
- Run the following to create and connect to the Kopia local backup repo
- This lives under `/opt/minecraft-backups`
```
kopia repository create filesystem --path /opt/minecraft-backups
kopia repository connect filesystem --path /opt/minecraft-backups
```
- Now take a snapshot of your Minecraft folder to confirm it works
```
kopia snapshot create /opt/minecraft
kopia snapshot list
```
- You should now have a snapshot, so the backups work!
- You can also modify the Kopia policy for backup retention using the following example commands
```
kopia policy set --global --keep-hourly 24
kopia policy set --global --keep-daily 7
kopia policy set --global --keep-weekly 4
kopia policy set --global --keep-monthly 2
kopia policy set --global --keep-annual 0
```
- These commands will keep
  - 24 hourly backups (hourly backups for 1 day)
  - 7 daily backups (daily backups for 1 week)
  - 4 weekly backups (weekly backups for 1 month)
  - 2 monthly backups (1 backup per month for 2 months)
  - 0 yearly backups (enable this if you want)
- [Read the Kopia docs for more info](https://kopia.io/docs/)

## Backup script
- Now you need to modify `backup-server.sh` in `/opt/minecraft`
- The mcrcon password should be what you set in your Ansible config
- Just ensure that your 2 commands that matter are correct
- These are
```
kopia snapshot create /opt/minecraft
rclone sync /opt/minecraft-backups mega:
```
- This entire script does the following
  - Disables auto saving (prevents the snapshot copying files in use, which may become corrupt)
  - Does a manual save
  - Creates a backup using Kopia
  - Enables auto saving
  - rclones the backups folder to your rclone remote storage
- That should be it
- The Ansible config automatically creates an hourly cron job to run the backup script, so you should now get automatic hourly backups