# Mikxi
Head management of the Wobbling Goblin, with a penchant for gold.

## Prepare
*The following is only required when setting up the server.*

### On the remote server
Change the root password:

```
passwd
```

Create a user account for Ansible to do its things:

```
useradd --create-home deploy
passwd deploy
```

Authorize your SSH key and enable passwordless sudo:

```
mkdir /hom/deploy/.ssh
chmod 700 /home/deploy/.ssh
# Insert id_rsa.pub into authorized_keys
vi /home/deploy/.ssh/authorized_keys
chmod 400 /home/deploy/.ssh/authorized_keys
chown deploy:deploy /home/deploy -R
echo 'deploy ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/deploy'
```

### On your local machine
Get the `mikxi` repository:

```
git clone git@github.com:wobgob/mikxi.git; cd mikxi
```

Your Ansible hosts file should look something like:

```
/etc/ansible/hosts:
    [mikxi]
    prod ansible_host=123.456.789 ansible_python_interpreter=/usr/bin/python3
    test ansible_host=987.654.321 ansible_python_interpreter=/usr/bin/python3
    dev ansible_host=127.0.0.1 ansible_python_interpreter=/usr/bin/python3
```

Configure `prod`, `test`, and `dev` in `host_vars/prod.yml`, `host_vars/test.yml`, and `host_vars/dev.yml` respectively:

```
host_vars/*.yml:
    realmlist:
      name: <name>

    discord_bot_token: <discord-bot-token>
    discord_client_id: <discord-client-id>
    discord_guild_id: <discord-guild-id>
    db_uri: mysql://<user>:<pass>@<host>:<port>
    smtp_host: <smtp-host>
    smtp_user: <smtp-user>
    smtp_pass: <smtp-pass>
```

Configure `all` hosts in `group_vars/all.yml`:

```
group_vars/all.yml:
    company: <name>
    website: <url>
    noreply: <email>
```

Run the `common` role:
```
ansible-playbook --tags "common" site.yml
```

## Building
*The following is only required when setting up the server.*

On the remote server:

```
cd /home/azerothcore
git clone https://github.com/azerothcore/azerothcore-wotlk.git
azerothcore-wotlk/acore.sh compiler all
```

On your local machine:

```
ansible-galaxy collection install community.mysql
MYSQL_PASS=<password> ansible-playbook --tags "database" site.yml
```

On the remote server again:

```
`MYSQL_PASS=<password> ./acore.sh db-assembler import-all`
`DATAPATH_ZIP=$HOME/data.zip ./acore.sh client-data`
```

On your local machine again:

```
MYSQL_PASS=<password> ansible-playbook --tags "azerothcore" site.yml
DISCORD_BOT_TOKEN=<token> DISCORD_CLIENT_ID=<client-id> DISCORD_GUILD_ID=<guild-id> MYSQL_PASS=<password> ansible-playbook --tags "winzig" site.yml
```

You should now find startup scripts in `/home/azerothcore` and `/home/winzig`. Run these scripts as either `azerothcore` or `winzig`.

## Updating
On the remote server:

```
cd /home/azerothcore/azerothcore-wotlk
./acore.sh compiler build
MYSQL_PASS=<password> ./acore.sh db-assembler import-updates
```

On your local machine:

```
MYSQL_PASS=<password> ansible-playbook --tags "azerothcore" site.yml
DISCORD_BOT_TOKEN=<token> DISCORD_CLIENT_ID=<client-id> DISCORD_GUILD_ID=<guild-id> MYSQL_PASS=<password> ansible-playbook --tags "winzig" site.yml
```