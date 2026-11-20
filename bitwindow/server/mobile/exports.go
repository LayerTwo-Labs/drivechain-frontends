// Package main builds bitwindowd and drivechaind into one library for an app
// that cannot start child processes.
package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"encoding/json"
	"unsafe"
)

var current = newBackend()

// BitwindowStart starts bitwindowd and drivechaind in this process. config is
// a JSON startConfig. It returns NULL, or an error the caller frees with
// BitwindowFree.
//
//export BitwindowStart
func BitwindowStart(config *C.char) *C.char {
	if err := current.start(C.GoString(config)); err != nil {
		return C.CString(err.Error())
	}
	return nil
}

// BitwindowStop asks bitwindowd and drivechaind to stop. BitwindowStatus
// reports when they are gone.
//
//export BitwindowStop
func BitwindowStop() {
	current.stop()
}

// BitwindowStatus returns a JSON status the caller frees with BitwindowFree.
//
//export BitwindowStatus
func BitwindowStatus() *C.char {
	raw, err := json.Marshal(current.status())
	if err != nil {
		return C.CString(`{"running":false,"error":"encode status: ` + err.Error() + `"}`)
	}
	return C.CString(string(raw))
}

// BitwindowFree frees a string from this library.
//
//export BitwindowFree
func BitwindowFree(p *C.char) {
	C.free(unsafe.Pointer(p))
}

func main() {}
