#cloud-config
cloud_final_modules:
- [users-groups,always]
users:
  - name: admin
    groups: [ wheel ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    shell: /bin/bash
    ssh-authorized-keys:
    - ${public_key}
