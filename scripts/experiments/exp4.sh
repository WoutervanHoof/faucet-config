#! /usr/bin/runscript

set a 0
loop:
if a = 10 goto finish
! ssh wouter@10.42.0.10 /home/wouter/faucet-config/scripts/experiments/stop-tcpdump-exp4.sh
! /home/wouter/projects/thesis/faucet-config/scripts/reset_demo.sh
! ssh wouter@10.42.0.10 /home/wouter/faucet-config/scripts/experiments/start-tcpdump-exp4.sh

inc a

send ot reset\n
expect {
    timeout 5 goto ifconfig
}

ifconfig:
send ot ifconfig up\n
expect {
    uart:~$ goto attach
}

attach:
send ot thread start\n
expect {
    uart:~$ goto detach
}

detach:
sleep 5

send ot detach\n
expect {
    Done goto loop
}


finish:
print "Done!"