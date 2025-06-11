set a 0
loop:
if a = 100 goto blocked
! sleep 0.01
send ot ping fd99:aaaa:bbbb:200::2\n
inc a
expect {
    Done goto loop
}

blocked:
set a 0
loop2:
if a = 100 goto exit
! sleep 0.01
send ot ping fd99:aaaa:bbbb:300::2\n
inc a
expect {
    Done goto loop2
}

exit:
print "Done pinging"
