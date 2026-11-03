package paperpdf

import "fmt"

// QRMatrix is the module grid of one QR code.
type QRMatrix struct {
	// Size is the count of modules per side.
	Size int
	// Modules holds one byte per module, row-major from the top-left. 1 is dark, 0 is light.
	Modules []byte
}

// Validate returns an error if m is not the grid of a QR code version 1 to 40.
func (m QRMatrix) Validate() error {
	if m.Size < 21 || m.Size > 177 || (m.Size-17)%4 != 0 {
		return fmt.Errorf("QR size %d is not the size of a QR version", m.Size)
	}
	if len(m.Modules) != m.Size*m.Size {
		return fmt.Errorf("QR has %d modules, want %d", len(m.Modules), m.Size*m.Size)
	}
	for i, b := range m.Modules {
		if b > 1 {
			return fmt.Errorf("QR module %d has the value %d, want 0 or 1", i, b)
		}
	}
	return nil
}

// QR draws the code as a square of side size, with one filled rectangle per dark module.
func (p *Page) QR(x, y, size float64, m QRMatrix) error {
	if err := m.Validate(); err != nil {
		return err
	}
	module := size / float64(m.Size)
	p.setFill(Black)
	for row := range m.Size {
		for col := range m.Size {
			if m.Modules[row*m.Size+col] == 1 {
				p.rect(x+float64(col)*module, y+float64(row)*module, module, module)
			}
		}
	}
	// One fill for all modules, so that a viewer shows no seam between two dark modules.
	p.op("f")
	return nil
}
