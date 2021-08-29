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
mkdir /home/deploy/.ssh
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
    prod ansible_host=123.456.789 ansible_python_interpreter=/usr/bin/python3
    test ansible_host=987.654.321 ansible_python_interpreter=/usr/bin/python3
    dev ansible_host=127.0.0.1 ansible_python_interpreter=/usr/bin/python3

    [mikxi]
    prod
    test
    dev

    [winzig]
    prod
    dev
```

Configure `prod`, `test`, and `dev` in `host_vars/prod.yml`, `host_vars/test.yml`, and `host_vars/dev.yml` respectively:

```
host_vars/*.yml:
    realmlist:
      id: <int>
      port: <int>
      name: <name>

    discord:
      bot_token: <discord-bot-token>
      client_id: <discord-client-id>
      guild_id: <discord-guild-id>
    
    database:
      pass: <password>
      uri: mysql://<user>:<pass>@<host>:<port>
    
    smtp:
      host: <smtp-host>
      user: <smtp-user>
      pass: <smtp-pass>
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

To limit it to a certain host:

```
ansible-playbook --tags "common" --limit dev site.yml
```

## Building
*The following is only required when setting up the server.*

On the remote server:

```
cd /home/{dev,test,prod}
git clone https://github.com/azerothcore/azerothcore-wotlk.git
azerothcore-wotlk/acore.sh compiler all
```

Remember to clone any modules you might require.

On your local machine:

```
ansible-galaxy collection install community.mysql
ansible-playbook --tags "database" site.yml
```

On the remote server again:

```
DBLIST=<auth-db>,<char-db>,<world-db> MYSQL_PASS=<password> ./acore.sh db-assembler import-all
DATAPATH_ZIP=$HOME/data.zip ./acore.sh client-data
```

On your local machine again:

```
ansible-playbook --tags "azerothcore" site.yml
ansible-playbook --tags "winzig" site.yml
```

You should now find startup scripts in `/home/{dev,test,prod}` and `/home/winzig`. Run these scripts as either `dev`, `test`, `prod`, or `winzig`.

## Updating
On the remote server:

```
cd /home/{dev,test,prod}/azerothcore-wotlk
./acore.sh compiler build
DBLIST=<auth-db>,<char-db>,<world-db> MYSQL_PASS=<password> ./acore.sh db-assembler import-updates
```

On your local machine:

```
ansible-playbook --tags "azerothcore" site.yml
ansible-playbook --tags "winzig" site.yml
```