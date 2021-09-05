# Mikxi
Head management of the Wobbling Goblin, with a penchant for gold.

## Requirements
* Telegram account
* SMTP relay

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
echo 'deploy ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/deploy
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

    [common]
    prod
    test
    dev

    [acore]
    prod
    test
    dev

    [winzig]
    prod
    dev
```

Configure the server:

```
group_vars/all.yml:
    company: <company>
    website: <website>
    email: <company> <email>

    acore:
      git: <repo>
      version: <branch>
      modules:
        - name: <name>
          git: <repo>
          version: <branch>
        - name: <name>
          git: <repo>
          version: <branch>

    realmlist:
      id: <id>
      name: <name>
      address: <address>
      port: <port>

    mysql:
      user: <user>
      pass: <password>
      host: <host>
      port: <port>

    database:
      auth: <auth>
      characters: <characters>
      world: <world>
      backup:
        repo: <repo>
        version: <version>
        zip_pass: <password>
        telegram_api_id: <id>
        telegram_api_hash: <hash>
        telegram_chat_id: me

    backup:
      pass: <password>
      from: <email>
      to:
        - <email>

    discord:
      bot_token: <token>
      client_id: <id>
      guild_id: <id>

    smtp:
      host: <host>
      user: <user>
      pass: <password>
```

You can overwrite variables on a host-by-host basis in `host_vars/<host>.yml` (e.g., `host_vars/dev.yml`).

Run the `backup` role:

```
ansible-playbook --tags backup --limit <host> site.yml
```

And then the `common` role:

```
ansible-playbook --tags common --limit <host> site.yml
```

## Building
*The following is only required when setting up the server.*

On your local machine:

```
ansible-galaxy collection install community.mysql
ansible-playbook --tags "acore,winzig" --limit <host> site.yml
```

On the remote server:

```
/home/<host>/azerothcore-wotlk/acore.sh compiler all
```

You should now find `/home/<host>/startup.sh` and `/home/winzig/startup.sh` which run on boot.

## Updating
On your local machine:

```
ansible-playbook --tags "acore,winzig" site.yml
```

On the remote server:

```
/home/<host>/azerothcore-wotlk/acore.sh compiler build
```