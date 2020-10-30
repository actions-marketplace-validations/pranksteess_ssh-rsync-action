<div align="center">

# SSH Rsync Action

[![Action on GH marketplace][marketplace badge]][marketplace] &nbsp;
[![GitHub release][release badge]][latest release] &nbsp;
[![GitHub][LICENSE badge]][LICENSE]

</div>
# Description
Copy files from github workstation to a proxy, then copy them from proxy to your online server


# Usage

```yml
- name: Copy bin
  uses: pranksteess/ssh-rsync-action@v1.0
          
  with:
    key: ${{ secrets.RSYNC_KEY }}
    rsync_flags: ' -avzr --delete --progress '
    dst_host: 1.1.1.1
    dst_user: root
    proxy_host: 2.2.2.2
    proxy_user: root
    src_file: xxx.bin
    proxy_file_path: /tmp/proxy_file_save/
    dst_file_path: /usr/local/service/xxx/bin/
    ssh_after: |
      ssh -o StrictHostKeyChecking=no -p 22 root@1.1.1.1 "cd /usr/local/service/xxx/bin/ && md5sum xxx.bin && mv xxx xxx.old && mv xxx.new xxx && supervisorctl restart xxx"
```

more details see [action.yml](https://github.com/pranksteess/ssh-rsync-action/blob/main/action.yml)

















[marketplace badge]: https://img.shields.io/badge/GitHub-Marketplace-lightblue.svg
[marketplace]: https://github.com/marketplace/actions/ssh-and-rsync-setup
[LICENSE badge]: https://img.shields.io/github/license/Pendect/action-rsyncer.svg
[LICENSE]: https://github.com/pranksteess/ssh-rsync-action/blob/main/LICENSE
[release badge]: https://img.shields.io/badge/release-v1.0-blue
[latest release]: https://github.com/pranksteess/ssh-rsync-action/releases/latest
