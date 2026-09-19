package stratum

import (
	"fmt"
	"net"
)

// Interface is the part of a network interface that picks a LAN address.
type Interface struct {
	Flags net.Flags
	Addrs []net.Addr
}

// lanIPv4 returns the first private IPv4 address on an interface that is up
// and reaches other machines.
func lanIPv4(interfaces []Interface) (net.IP, bool) {
	for _, iface := range interfaces {
		if iface.Flags&net.FlagUp == 0 || iface.Flags&(net.FlagLoopback|net.FlagPointToPoint) != 0 {
			continue
		}
		for _, addr := range iface.Addrs {
			ipnet, ok := addr.(*net.IPNet)
			if !ok {
				continue
			}
			if ip := ipnet.IP.To4(); ip != nil && ip.IsPrivate() {
				return ip, true
			}
		}
	}
	return nil, false
}

// LANIPv4 returns the address miners on the local network reach this machine
// at. ok is false when the machine has no LAN address.
func LANIPv4() (ip net.IP, ok bool, err error) {
	system, err := net.Interfaces()
	if err != nil {
		return nil, false, fmt.Errorf("list network interfaces: %w", err)
	}
	interfaces := make([]Interface, 0, len(system))
	for _, iface := range system {
		addrs, err := iface.Addrs()
		if err != nil {
			return nil, false, fmt.Errorf("addresses of %s: %w", iface.Name, err)
		}
		interfaces = append(interfaces, Interface{Flags: iface.Flags, Addrs: addrs})
	}
	ip, ok = lanIPv4(interfaces)
	return ip, ok, nil
}
