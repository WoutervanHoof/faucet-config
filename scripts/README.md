# Scripts:
These scripts were all used to run the demo environments in which I ran my experiments.
I hope most are somewhat straightforward in their use, most support -h for a quick usage description.
The following table quickly explains their intended use:

| Script | Description |
| ------ | ----------- |
| activate_thread.sh | After setting up a demo environment, run this on the pi hosting the initial border router. It creates a new Thread network. | 
| allow_forwarding_hotspot.sh | Adjust firewall on laptop to allow packet forwarding to and from the pi's connected to the wifi hotspot on the laptop |
| join_thread.sh | After setting up a demo environment, run this on other pi's where the border router should join the existing Thread network. |
| network_layout.sh | Script containing definitions which specify IP ranges and addresses, is sourced by most other scripts. |
| ovs_helper.sh | File with a few helpfull ovs shortcuts. See: https://docs.openvswitch.org/en/latest/tutorials/faucet/ |
| reset_demo.sh | Run this to reset the config of the faucet docker container 
| run_demo.sh | This scripts sets up or destroys a demo environment on a raspberry pi. It starts an OVS switch and connects three containers: a border router, an "admin" container and an "attacker" container. |
| test_connections.sh | Helper script to check if all containers are connected and can reach each other, i.e. if faucet has configured the switch correctly. |
| trace.sh | Very limited helper script for dumpint OVS traces, is not configurable so edit the script to dump other traces. |

