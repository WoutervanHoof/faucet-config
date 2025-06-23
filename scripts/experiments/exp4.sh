#! /usr/bin/runscript

timeout 15000s

set a 0

loop:
    sleep 1
    ! ssh wouter@10.42.0.10  -- sudo /home/wouter/faucet-config/scripts/experiments/stop-tcpdump-exp4.sh
    ! ssh wouter@10.42.0.170 -- sudo /home/wouter/faucet-config/scripts/experiments/stop-tcpdump-exp4.sh
    ! ssh wouter@10.42.0.179 -- sudo /home/wouter/faucet-config/scripts/experiments/stop-tcpdump-exp4.sh
    set b 0
    if a = 100 goto finish
    ! /home/wouter/projects/thesis/faucet-config/scripts/reset_demo.sh

    inc a

    send ot reset\n
    expect {
        timeout 5 goto ifconfig
    }

ifconfig:
    ! ssh wouter@10.42.0.10  -- sudo /home/wouter/faucet-config/scripts/experiments/start-tcpdump-exp4.sh triple_1
    ! ssh wouter@10.42.0.170 -- sudo /home/wouter/faucet-config/scripts/experiments/start-tcpdump-exp4.sh triple_2
    ! ssh wouter@10.42.0.179 -- sudo /home/wouter/faucet-config/scripts/experiments/start-tcpdump-exp4.sh triple_3
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
        child goto test_mud_setup
        timeout 10 goto error
    }

test_mud_setup:
    if b = 10 goto error
    inc b
    expect {
        Done\r goto ping
        timeout 10 goto error
    }

ping:
    send ot ping fd99:aaaa:bbbb:200::2
    expect {
        "1 packets transmitted, 1 packets received." goto detach
        "1 packets transmitted, 0 packets received." goto test_mud_setup
        timeout 10 goto error
    }

detach:
    sleep 1
    send ot detach\n
    expect {
        Done\r goto loop
    }

finish:
    print "Done!"
    exit 0

error:
    print "Something went wrong"
    goto detach
