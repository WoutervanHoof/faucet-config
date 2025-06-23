#! /usr/bin/runscript

timeout 1500s

set a 0
loop:
if a = 5 goto finish
! ssh wouter@10.42.0.10 -- sudo /home/wouter/faucet-config/scripts/experiments/stop-tcpdump-exp4.sh
# ! ssh wouter@10.42.0.170 -- sudo /home/wouter/faucet-config/scripts/experiments/stop-tcpdump-exp4.sh
! /home/wouter/projects/thesis/faucet-config/scripts/reset_demo.sh

inc a

send ot reset\n
expect {
    timeout 5 goto ifconfig
}

ifconfig:
! ssh wouter@10.42.0.10 -- sudo /home/wouter/faucet-config/scripts/experiments/start-tcpdump-exp4.sh test_1
# ! ssh wouter@10.42.0.170 -- sudo /home/wouter/faucet-config/scripts/experiments/start-tcpdump-exp4.sh double_2
send ot ifconfig up\n
expect {
    uart:~$ goto attach
}

attach:
send ot thread start\n
expect {
    uart:~$ goto test_state
}

test_state:
sleep 2
send ot state\n
expect {
    detached goto test_state
    child goto detach
    timeout 10 goto error
}

detach:
sleep 1
send ot detach\n
expect {
    Done goto loop
}

finish:
print "Done!"
exit 0

error:
print "Something went wrong"
exit 1
