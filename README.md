# drone-rsync

This is a plugin for [Drone](https://drone.io) to sync files to a remote server using rsync.

## Why?

There are already a few plugins for rsync, but they all have crazy assumptions like "default user is root" or "you don't need to check the host fingerprint, just ignore it." Also, I wanted to have the ability to set the number of retries for rsync in case the connection is lost mid-sync or something like that.

## Usage

```yaml
- name: deploy
  image: ghcr.io/alkk/drone-rsync:1.1
  settings:
      host:
          from_secret: target_host
      port: 22 # optional
      host_fingerprint: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeoCi9QHIDAVqXXntEexuvoXgtrFANamEbm19BN8khy
      user:
          from_secret: user
      key:
          from_secret: key # can be base64 encoded
      source: # either string or list of strings
          - build/
          - static/
      destination: /remote/destination
      retries: 3 # default, optional
      retry_interval: 5 # in seconds, default, optional
      delete: true # rsync --delete if key exists
      extra: --verbose --chmod=Dg+w,Fg+w # any additional rsync options
```

## Supported parameters

-   `host` - target host, required.
-   `port` - target port, if not set, default port will be used.
-   `host_fingerprint` - target host fingerprint, can be either in format "keytype encoded_key" or complete known_hosts file encoded with base64. If not set, `StrictHostKeyChecking=no` will be used. Example: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeoCi9QHIDAVqXXntEexuvoXgtrFANamEbm19BN8khy`.
-   `user` - target user, required.
-   `key` - private key, required. Optionally can be base64 encoded.
-   `source` - source files. Either string or list of string.
-   `destination` - destination directory.
-   `retries` - number of retries, default is 3. Set to 1 to disable retries.
-   `retry_interval` - interval between retries, default is 5 seconds.
-   `delete` - if key exists (value does not matter), rsync will be called with `--delete` option.
-   `extra` - any additional rsync options.

## Multiline secrets

Multiline secrets works just fine, but you can't set them using web interface. There are two options:

-   Encode your secret with base64 first

-   Use drone command line tools to set secrets:

    ```sh
    drone secret add --repository … --name deploy_key --data @/path/to/file

    # or

    drone orgsecret add orgname1 deploy_key @/path/to/file
    ```
