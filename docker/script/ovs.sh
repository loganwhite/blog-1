# add the namespaces
ip netns add ns1
ip netns add ns2
# create the switch
BRIDGE=ovs-test
ovs-vsctl add-br $BRIDGE
#
#### PORT 1
# create an internal ovs port
ovs-vsctl add-port $BRIDGE tap1 -- set Interface tap1 type=internal
# attach it to namespace
ip link set tap1 netns ns1
# set the ports to up
ip netns exec ns1 ip link set dev tap1 up
#
#### PORT 2
# create an internal ovs port
ovs-vsctl add-port $BRIDGE tap2 -- set Interface tap2 type=internal
# attach it to namespace
ip link set tap2 netns ns2
# set the ports to up
ip netns exec ns2 ip link set dev tap2 up

# now assign the ip addresses
ip netns exec ns1 ip addr add 192.168.0.1 dev tap1
ip netns exec ns2 ip addr add 192.168.0.2 dev tap2
ifconfig ovs-test 192.168.0.100

# add default route
ip netns exec ns1 ip route add default dev tap1
ip netns exec ns2 ip route add default dev tap2

# test
ip netns exec ns1 ping 192.168.0.2
