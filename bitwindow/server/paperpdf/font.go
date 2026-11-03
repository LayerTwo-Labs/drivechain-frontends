package paperpdf

import (
	"fmt"
	"strings"
)

// Helvetica AFM ascender and descender, as a fraction of the font size.
const (
	ascent  = 0.718
	descent = 0.207
	// lineHeight is the height of one line box.
	lineHeight = ascent + descent
	// linePitch is the distance between the tops of two wrapped lines.
	linePitch = 1.15
)

const bullet = '•'

// winAnsiBullet is the WinAnsiEncoding code of the bullet.
const winAnsiBullet = 0x95

// Glyph widths from the Adobe AFM files, in 1/1000 of the font size, for the characters 32 to 126.
var helveticaWidths = [95]int{
	278, 278, 355, 556, 556, 889, 667, 191, 333, 333, 389, 584, 278, 333, 278, 278,
	556, 556, 556, 556, 556, 556, 556, 556, 556, 556, 278, 278, 584, 584, 584, 556,
	1015, 667, 667, 722, 722, 667, 611, 778, 722, 278, 500, 667, 556, 833, 722, 778,
	667, 778, 722, 667, 611, 722, 667, 944, 667, 667, 611, 278, 278, 278, 469, 556,
	333, 556, 556, 500, 556, 556, 278, 556, 556, 222, 222, 500, 222, 833, 556, 556,
	556, 556, 333, 500, 278, 556, 500, 722, 500, 500, 500, 334, 260, 334, 584,
}

var helveticaBoldWidths = [95]int{
	278, 333, 474, 556, 556, 889, 722, 238, 333, 333, 389, 584, 278, 333, 278, 278,
	556, 556, 556, 556, 556, 556, 556, 556, 556, 556, 333, 333, 584, 584, 584, 611,
	975, 722, 722, 722, 722, 667, 611, 778, 722, 278, 556, 722, 611, 833, 722, 778,
	667, 778, 722, 667, 611, 722, 667, 944, 667, 667, 611, 333, 278, 333, 584, 556,
	333, 556, 611, 556, 611, 556, 333, 611, 611, 278, 278, 556, 278, 889, 611, 611,
	611, 611, 389, 556, 333, 611, 556, 778, 556, 556, 500, 389, 280, 389, 584,
}

const bulletWidth = 350

func glyphWidth(f Font, r rune) int {
	if r == bullet {
		return bulletWidth
	}
	if r < 32 || r > 126 {
		return 0
	}
	if f == HelveticaBold {
		return helveticaBoldWidths[r-32]
	}
	return helveticaWidths[r-32]
}

// TextWidth returns the width of s in points.
func TextWidth(f Font, size float64, s string) float64 {
	total := 0
	for _, r := range s {
		total += glyphWidth(f, r)
	}
	return float64(total) * size / 1000
}

func encodeWinAnsi(s string) ([]byte, error) {
	out := make([]byte, 0, len(s))
	for _, r := range s {
		switch {
		case r == bullet:
			out = append(out, winAnsiBullet)
		case r >= 32 && r <= 126:
			out = append(out, byte(r))
		default:
			return nil, fmt.Errorf("text has the character %U, which the PDF font cannot show", r)
		}
	}
	return out, nil
}

// Wrap splits s into lines no wider than maxWidth. It breaks at spaces, and inside a word that is too wide.
func Wrap(f Font, size, maxWidth float64, s string) []string {
	var lines []string
	var line string
	for _, word := range strings.Fields(s) {
		candidate := word
		if line != "" {
			candidate = line + " " + word
		}
		if TextWidth(f, size, candidate) <= maxWidth {
			line = candidate
			continue
		}
		if line != "" {
			lines = append(lines, line)
		}
		rest := []rune(word)
		for TextWidth(f, size, string(rest)) > maxWidth {
			cut := 1
			for cut < len(rest) && TextWidth(f, size, string(rest[:cut+1])) <= maxWidth {
				cut++
			}
			lines = append(lines, string(rest[:cut]))
			rest = rest[cut:]
		}
		line = string(rest)
	}
	if line != "" {
		lines = append(lines, line)
	}
	return lines
}

// TextHeight returns the height of n wrapped lines.
func TextHeight(size float64, n int) float64 {
	if n == 0 {
		return 0
	}
	return lineHeight*size + float64(n-1)*linePitch*size
}
