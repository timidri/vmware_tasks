# vmware_tasks

This module contains tasks for a PoC showing Relay+PE capabilities in managing VMWare-backed infrastructure.

## PoC setup

1. Install PE 2021.5 on an on-prem VM with network access to a VCenter cluster
1. Install newest Powershell

    ```bash
    curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
    yum install -y powershell
    ```

1. Install PowerCLI

    ```bash
    pwsh
    Install-Module VMware.PowerCLI
    ```

1. Set the `HOME` environment variable for the pxp-agent service. Otherwize, pxp-agent running a powershell task won't be able to find and import available modules:

     ```bash
    echo "HOME=/root" >> /etc/sysconfig/pxp-agent
    systemctl restart pxp-agent
    ```

1. Install this module
1. Check that you can see the tasks inside the module

    ```bash
    puppet task show|grep vmware
    ```

  You should see the tasks in this module listed.

1. Run a test task

    ```bash
    puppet task run vmware_tasks::test -n <primary_certname>
    ```

1. Install the modified `puppetlabs-lvm` module in `/opt/puppetlabs/puppet/modules` so PE will see the plans inside it even if CodeManager is not used:

    ```bash
    git clone https://github.com/timidri/puppetlabs-lvm.git lvm
    cd lvm
    git checkout fix-logical-volumes-fact
    puppet agent -t
    ```

1. Check whether you can see the module's plan and facts:

    ```bash
    puppet plan show|grep lvm
    facter -p logical_volumes
    ```

1. Install the [puppetlabs-relay](https://forge.puppet.com/modules/puppetlabs/relay) module and use it to install and configure the relay agent.
1. Create a Relay workflow running a task inside vmware_tasks
