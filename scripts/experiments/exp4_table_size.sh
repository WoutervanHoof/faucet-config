#! /usr/bin/runscript

timeout 15000s

set a 0
# Set count to 0, to track iterations in get_base and after scripts
! echo "0" > count.txt

loop:    
    set b 0
    if a = 100 goto finish

    ! /home/wouter/projects/thesis/faucet-config/scripts/reset_demo.sh

    inc a

    ! echo "$(($(cat count.txt) + 1))" > count.txt
    

    send ot reset\n
    expect {
        timeout 6 goto ifconfig
    }

ifconfig:
    ! ./exp4_dump_tables.sh "1" "base" "short_double" 
    ! ./exp4_dump_tables.sh "2" "base" "short_double" 
    # ! ./exp4_dump_tables.sh "3" "base" "triple" 

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
    sleep 1
    send ot state\n
    expect {
        detached goto test_state
        child goto test_mud_setup
        router goto test_mud_setup
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
    ! ./exp4_dump_tables.sh "1" "mud" "short_double" 
    ! ./exp4_dump_tables.sh "2" "mud" "short_double" 
    # ! ./exp4_dump_tables.sh "3" "mud" "tiple" 

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
