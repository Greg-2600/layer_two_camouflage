# layer_two_camouflage
Blend into a network segment at the datalink layer


* 1.) Send a broadcast frame to the network to bait devices to reveal themselves
* 2.) Find the most common network interface card manufacturer
* 3.) Generate a mac address that looks like it was manufactured by that vendor
* 4.) Apply the mac address to the OSX machine's interface
* 5.) Request an IP address from the network

Tested in OSX, will not work in linux.

Usage:

  sudo bash layer_two_camouflage.sh
