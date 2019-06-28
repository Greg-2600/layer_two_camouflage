#!/bin/bash

get_broadcast_address() {
# parse the broadcast address from local interface
	ifconfig|               # get interface configuration
	grep netmask|           # remove everything but the line containing subnet address
	grep -v "\-\->"|        # remove tunnel interfaces (VPN, etc)
	grep -v "127\.0\.0\.1"| # remove loopback interface
	awk {'print $6'}        # extract broadbaset field
}


set_arp_cache() {
# populate the arp cache with device that respond to broadcasts
	# send one frame to ff:ff:ff:ff:ff:ff
	ping -o $(get_broadcast_ddress)
}


get_arp_cache() {
# get a list of IP and mac address via address resolution protocol
	arp -a|                 # list all devices known to protocol
	tr -d "()"|             # remove parenthesis
	awk {'print $2, $4'}    # extract mac and ip
}


get_common_mac_prefix() {
# find the most common network interface manufactorer on this network segment
	echo $(get_arp_cache)|  # internal function to get data from arp cache
	awk {'print $4'}|       # extract just the mac addresses
	cut -f1,2,3 -d :|       # extract just the manufacturer prefix
	sort -t : -k 1,2|       # sort the manufacturer prefix
	uniq -c|                # count how many of each and group
	sort|                   # sort result of count
	tail -1|                # extract the last line which contains max
	awk {'print $2'}        # select the prefix sans count
}


get_random_mac_suffix() {
	# generate a random string of hexadecimal characters
	openssl rand -hex 3|
	# group the string into two characters seperated by column
	sed 's/\(..\)/\1:/g; s/.$//'
}


get_camouflage_mac() {
# put a new mac address string together
	# get the most common hardware manufacturer on the network
	prefix=$(get_common_mac_prefix)
	# append the random host bits to the end
	suffix=$(get_random_mac_suffix)
	# return an address that blends with the current data link layer deployment logical addressing
	echo "$prefix:$suffix"
}


set_camouflage_mac() {
# change the mac address of an interface
	# accept the mac as an argument to this function
	this_mac=$1
	# move to root and change the interface mac address
	sudo ifconfig en2 ether $this_mac
}


set_dhcp_request() {
# send a DHCP Lease Request broadcast frame
	# command to send to scutil
	command="add State:/Network/Interface/en2/RefreshConfiguration temporary"
	# run scutil with the command
	echo $command|sudo scutil
}


main() {
# send a broadcast frame to the network to bait devices to reveal themselves
# find the most common network interface card manufacturer
# generate a mac address that looks like it was manufactured by that vendor
# apply the mac address to the OSX machine's interface
# request an IP address from the network

	mac=$(get_camouflage_mac) # set the value of the new mac
	set_camouflage_mac $mac   # apply the new mac to this computer
	set_dhcp_request          # request a IP lease on this network
}


main
