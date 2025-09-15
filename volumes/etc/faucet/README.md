# README
Config files for both faucet and gauge to be used with docker-compose of the faucet git repo.

gauge.yaml is the default config as suggested in [the Faucet docs](https://docs.faucet.nz/en/latest/tutorials/first_time.html).

To set a policy for faucet: `cp volumes/etc/faucet_base.yaml volumes/etc/faucet.yaml`
The compose override configures faucet to listen to changes in ./faucet.yaml, so any change triggers an update to the config.   

faucet_base.yaml sets up a base environment with three switches, each with three ports and one VLAN per port.
All vlans have two base ACL policies: allow-mud, which forwards all MUD messages to the controller and block-thread, which blocks all traffic to and from the Thread prefix.
New MUD-based policies will be inserted after allow-mud and before block-thread.

The ./acls directory is used by the mudmanager. New MUD-based policies are stored there. The MUD manager also includes these ACLS in ./faucet.yaml and updates the acls_in object for all VLANs to include the new policy.