# What is this?
- This is a repo for my Terraform config for Oracle Cloud
- This config automatically creates a Minecraft server running Purpur server or All The Mods 9 (depending on the roles you choose)
- This server is resilient to reboots and crashes, so it should be pretty reliable
- This performs the following steps
  - Spins up a VM in Oracle Cloud's Always Free tier with the following parameters
    - ARM CPU architecture
    - Ubuntu Server 22.04 (currently 2023-09 image)
    - 4 OCPUs (4 vCPUs)
    - 24GB RAM (16GB assigned to the server)
  - Creates a DNS record for your server in Cloudflare DNS
  - Triggers Ansible to
    - Automate OS patching
    - Install Zabbix agent for monitoring
    - Configure automated Minecraft backups locally with copies to Mega
    - Install and setup Minecraft server

# Requirements
- Linux machine to run this from (WSL works on Windows)
- [Terraform](https://tfswitch.warrensbox.com/Install/)
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
- Copy the example vars files
```
cp terraform.tfvars.example terraform.tfvars
cp backend.tf.example backend.tf
```
- Edit the files and fill in your vars (using variables.tf as a reference)
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
chmod 600 ansible-vault-key
```
- Initialize Terraform, plan and apply
```
terraform init
terraform plan
terraform apply
```
- Note that this will probably fail for the first time on the Ansible step
- This is because the VM isn't ready for SSH connections yet
- If it does fail, just re-run the `terraform apply` again
- It may also fail due to capacity issues on Oracle's end
- If this happens, create a cron job to run every 6 hours that does a `terraform apply -auto-approve` to automatically create the VM for you
- I'd also recommend you read through the roles folder and tweak the config to what you want
- That should be it! Give it a few minutes and your server should be up

# Backups
- Backups run every hour via a cron job as root
- The backups go to a local repo under `/opt/minecraft/backups/kopia`
- The backup folder is then rcloned to Mega so there's an off-server copy

## rclone config
- Run rclone on a machine to set up a config file for Mega
- This will contain your username and password
- Copy those, encrypt them and use them as vars in `ansible-config.yml`

## Kopia config
- You just need to provide a Kopia repo password in `ansible-config.yml`
- Kopia then uses the below policy settings
```
kopia policy set --global --keep-hourly 24
kopia policy set --global --keep-daily 7
kopia policy set --global --keep-weekly 4
kopia policy set --global --keep-monthly 12
kopia policy set --global --keep-annual 3
```
- These commands will keep
  - 24 hourly backups (hourly backups for 1 day)
  - 7 daily backups (daily backups for 1 week)
  - 4 weekly backups (weekly backups for 1 month)
  - 12 monthly backups (monthly backups for a year)
  - 3 yearly backups (3 years of backups)
- [Read the Kopia docs for more info](https://kopia.io/docs/)

## Backup script
- The backup script does the following
  - Disables auto saving (prevents the snapshot copying files in use, which may become corrupt)
  - Does a manual save
  - Creates a backup using Kopia
  - Enables auto saving
  - rclones the backups folder to your rclone Mega storage