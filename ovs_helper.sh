
dump-flows () {
  sudo ovs-ofctl -OOpenFlow13 --names --no-stat dump-flows "$@" \
    | sed 's/cookie=0x5adc15c0, //'
}

save-flows () {
  sudo ovs-ofctl -OOpenFlow13 --no-names --sort dump-flows "$@"
}

diff-flows () {
  sudo ovs-ofctl -OOpenFlow13 diff-flows "$@" | sed 's/cookie=0x5adc15c0 //'
}
