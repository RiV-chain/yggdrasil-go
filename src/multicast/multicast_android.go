//go:build android
// +build android

package multicast

import (
	"fmt"
	"os"
	"syscall"

	"golang.org/x/sys/unix"
)

func (m *Multicast) _multicastStarted() {

}

func (m *Multicast) multicastReuse(network string, address string, c syscall.RawConn) error {
	var control error
	var reuseaddr error

	control = c.Control(func(fd uintptr) {
		// Previously we used SO_REUSEPORT here, but that meant that machines running
		// RiV-mesh nodes as different users would inevitably fail with EADDRINUSE.
		// The behaviour for multicast is similar with both, so we'll use SO_REUSEADDR
		// instead.
		if reuseaddr = unix.SetsockoptInt(int(fd), unix.SOL_SOCKET, unix.SO_REUSEADDR, 1); reuseaddr != nil {
			fmt.Fprintf(os.Stderr, "Failed to set SO_REUSEADDR on socket: %s\n", reuseaddr)
		}
	})
	return control
}
