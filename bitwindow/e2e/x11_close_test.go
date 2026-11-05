//go:build e2e && !windows

package e2e

import (
	"errors"
	"fmt"
	"slices"

	"github.com/jezek/xgb"
	"github.com/jezek/xgb/xproto"
)

// closeLinuxWindow sends WM_DELETE_WINDOW to each window of pid, the same
// request a window manager sends when the user clicks the close button.
func closeLinuxWindow(pid int) error {
	conn, err := xgb.NewConn()
	if err != nil {
		return fmt.Errorf("connect to X server: %w", err)
	}
	defer conn.Close()

	atoms := make(map[string]xproto.Atom)
	for _, name := range []string{"WM_PROTOCOLS", "WM_DELETE_WINDOW", "_NET_WM_PID"} {
		reply, err := xproto.InternAtom(conn, true, uint16(len(name)), name).Reply()
		if err != nil {
			return fmt.Errorf("intern atom %s: %w", name, err)
		}
		if reply.Atom == xproto.AtomNone {
			return fmt.Errorf("X server has no atom %s", name)
		}
		atoms[name] = reply.Atom
	}

	root := xproto.Setup(conn).DefaultScreen(conn).Root
	windows, err := deletableWindows(conn, root, uint32(pid), atoms)
	if err != nil {
		return err
	}
	if len(windows) == 0 {
		return fmt.Errorf("no window of pid %d accepts WM_DELETE_WINDOW", pid)
	}
	for _, window := range windows {
		event := xproto.ClientMessageEvent{
			Format: 32,
			Window: window,
			Type:   atoms["WM_PROTOCOLS"],
			Data: xproto.ClientMessageDataUnionData32New([]uint32{
				uint32(atoms["WM_DELETE_WINDOW"]), uint32(xproto.TimeCurrentTime), 0, 0, 0,
			}),
		}
		if err := xproto.SendEventChecked(conn, false, window, xproto.EventMaskNoEvent, string(event.Bytes())).Check(); err != nil {
			return fmt.Errorf("send WM_DELETE_WINDOW to window %d: %w", window, err)
		}
	}
	return nil
}

func deletableWindows(conn *xgb.Conn, parent xproto.Window, pid uint32, atoms map[string]xproto.Atom) ([]xproto.Window, error) {
	tree, err := xproto.QueryTree(conn, parent).Reply()
	if err != nil {
		return nil, fmt.Errorf("query X window tree: %w", err)
	}
	var found []xproto.Window
	for _, child := range tree.Children {
		owner, err := xproto.GetProperty(conn, false, child, atoms["_NET_WM_PID"], xproto.AtomCardinal, 0, 1).Reply()
		if err != nil {
			return nil, fmt.Errorf("read _NET_WM_PID of window %d: %w", child, err)
		}
		if owner.ValueLen == 1 && xgb.Get32(owner.Value) == pid {
			deletable, err := acceptsDelete(conn, child, atoms)
			if err != nil {
				return nil, err
			}
			if deletable {
				found = append(found, child)
			}
		}
		nested, err := deletableWindows(conn, child, pid, atoms)
		if err != nil {
			return nil, err
		}
		found = append(found, nested...)
	}
	return found, nil
}

func acceptsDelete(conn *xgb.Conn, window xproto.Window, atoms map[string]xproto.Atom) (bool, error) {
	protocols, err := xproto.GetProperty(conn, false, window, atoms["WM_PROTOCOLS"], xproto.AtomAtom, 0, 32).Reply()
	if err != nil {
		return false, fmt.Errorf("read WM_PROTOCOLS of window %d: %w", window, err)
	}
	if protocols.Format != 32 && protocols.ValueLen > 0 {
		return false, errors.New("WM_PROTOCOLS has an unexpected format")
	}
	values := make([]xproto.Atom, 0, protocols.ValueLen)
	for i := uint32(0); i < protocols.ValueLen; i++ {
		values = append(values, xproto.Atom(xgb.Get32(protocols.Value[i*4:])))
	}
	return slices.Contains(values, atoms["WM_DELETE_WINDOW"]), nil
}
