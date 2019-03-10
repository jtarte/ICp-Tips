# Ubuntu 18.04

When I moved my lab environment from Ubuntu 16.04 to 18.04, I discovered some changes at Operating System level that could have impact on the behavior of ICP cluster. This page is to summerize these points and shows what is the solution I found to address it.

## Preserve IP address after a reboot

In Ubuntu 18.04,  the built-in network config of Ubuntu 18.04 no longer uses the NIC Mac address as the default id for DHCP.
So if you don't have static IP addresses in your lab, but your are using DHCP, it could generate a problem. After each reboot, a VM will get a new IP adddress. As ICP is working with node IP addresses, it generates problme in the config of the cluster.

To avoid this problem, you should configure the netplan in order to use the mac address of the NIC as identifier for the DHCP.

* Edit the `/etc/netplan/xxxx.yaml` describing your NIC and change the confg to add the `dhco-identifier` param
```
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    ens160:
      dhcp4: yes
      dhcp-identifier: mac
```
* Apply the change by doing the command:
```
sudo netplan apply
```

With this config, your VM will keep their IP address after a reboot.

## DNS management

Ubuntu 18.04 uses, by default, a local DNS. Systemd-resolved moves and replaces /etc/resolv.conf with a stub file that can cause a fatal forwarding loop when resolving names in upstream servers. This can be fixed manually by using kubelet’s `--resolv-conf` flag to point to the correct resolv.conf (With systemd-resolved, this is /run/systemd/resolve/resolv.conf).

If nothing is done, I saw a over CPU consumption related to coreDNS process

For ICP installation, in order to fix the issues, modify the config.yaml:
* set the `lookback_dns` to `true`
* add `--resolv.conf`param to point the right DNS config file (`/run/systemd/resolve/resolv.conf`) on the `kubelet_extra_args`.
```
kubelet_extra_args: ["--resolv-conf /run/systemd/resolve/resolv.conf"]
```

This issue is identified and should be addressed by product on > 3.1.2.
