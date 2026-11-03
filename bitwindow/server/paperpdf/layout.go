package paperpdf

// block is one part of a page layout.
type block interface {
	// size returns the width and the height of the block in a slot of width maxWidth.
	size(maxWidth float64) (w, h float64)
	// draw draws the block in the box with the top-left corner x, y and the width w from size.
	draw(p *Page, x, y, w float64) error
}

type gap float64

func (g gap) size(float64) (w, h float64)               { return 0, float64(g) }
func (gap) draw(*Page, float64, float64, float64) error { return nil }

type text struct {
	font  Font
	pt    float64
	align Align
	color Color
	value string
}

func (t text) lines(maxWidth float64) []string {
	return Wrap(t.font, t.pt, maxWidth, t.value)
}

func (t text) size(maxWidth float64) (w, h float64) {
	lines := t.lines(maxWidth)
	if len(lines) == 1 {
		w = TextWidth(t.font, t.pt, lines[0])
	} else {
		w = maxWidth
	}
	return w, TextHeight(t.pt, len(lines))
}

func (t text) draw(p *Page, x, y, w float64) error {
	if t.align == AlignCenter {
		x += w / 2
	}
	for i, line := range t.lines(w) {
		if err := p.Text(x, y+float64(i)*linePitch*t.pt, t.font, t.pt, t.align, t.color, line); err != nil {
			return err
		}
	}
	return nil
}

type qr struct {
	side   float64
	matrix QRMatrix
}

func (q qr) size(float64) (w, h float64) { return q.side, q.side }

func (q qr) draw(p *Page, x, y, _ float64) error {
	return p.QR(x, y, q.side, q.matrix)
}

type column struct {
	align Align
	items []block
}

func (c column) size(maxWidth float64) (w, h float64) {
	for _, item := range c.items {
		iw, ih := item.size(maxWidth)
		w = max(w, iw)
		h += ih
	}
	return w, h
}

func (c column) draw(p *Page, x, y, w float64) error {
	for _, item := range c.items {
		iw, ih := item.size(w)
		ix := x
		if c.align == AlignCenter {
			ix += (w - iw) / 2
		}
		if err := item.draw(p, ix, y, iw); err != nil {
			return err
		}
		y += ih
	}
	return nil
}

// box is a bordered block around a child. The border takes no space.
type box struct {
	padding   float64
	lineWidth float64
	radius    float64
	color     Color
	child     block
}

func (b box) size(maxWidth float64) (w, h float64) {
	cw, ch := b.child.size(maxWidth - 2*b.padding)
	return cw + 2*b.padding, ch + 2*b.padding
}

func (b box) draw(p *Page, x, y, w float64) error {
	_, h := b.size(w)
	p.StrokeRect(x, y, w, h, b.radius, b.lineWidth, b.color)
	return b.child.draw(p, x+b.padding, y+b.padding, w-2*b.padding)
}
