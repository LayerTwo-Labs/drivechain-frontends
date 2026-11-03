// Package paperpdf writes the paper wallet and paper check PDF documents.
package paperpdf

import (
	"bytes"
	"errors"
	"fmt"
	"strconv"
	"strings"
)

// A4 landscape page size in points.
const (
	PageWidth  = 841.8898
	PageHeight = 595.2756
)

// Font is one of the two base-14 fonts that the writer uses.
type Font int

const (
	Helvetica Font = iota
	HelveticaBold
)

// Align is the horizontal alignment of a text line.
type Align int

const (
	AlignLeft Align = iota
	AlignCenter
)

// Color is an RGB color with components from 0 to 1.
type Color struct{ R, G, B float64 }

var Black = Color{0, 0, 0}

// Page is one page of a Document. Coordinates are in points, from the top-left corner.
type Page struct {
	content bytes.Buffer
}

// Document is a PDF 1.4 document of A4 landscape pages.
type Document struct {
	pages []*Page
}

// AddPage adds an empty page to the end of the document.
func (d *Document) AddPage() *Page {
	p := &Page{}
	d.pages = append(d.pages, p)
	return p
}

func num(v float64) string {
	s := strconv.FormatFloat(v, 'f', 3, 64)
	s = strings.TrimRight(strings.TrimRight(s, "0"), ".")
	if s == "-0" {
		return "0"
	}
	return s
}

func (p *Page) op(args ...string) {
	for i, a := range args {
		if i > 0 {
			p.content.WriteByte(' ')
		}
		p.content.WriteString(a)
	}
	p.content.WriteByte('\n')
}

func (p *Page) setFill(c Color) {
	p.op(num(c.R), num(c.G), num(c.B), "rg")
}

func (p *Page) setStroke(c Color, width float64) {
	p.op(num(c.R), num(c.G), num(c.B), "RG", num(width), "w")
}

// Text draws one line of text. y is the top of the line box. For AlignCenter, x is the center.
func (p *Page) Text(x, y float64, font Font, size float64, align Align, c Color, s string) error {
	encoded, err := encodeWinAnsi(s)
	if err != nil {
		return err
	}
	if align == AlignCenter {
		x -= TextWidth(font, size, s) / 2
	}
	baseline := PageHeight - (y + ascent*size)
	p.setFill(c)
	p.op("BT", fontName(font), num(size), "Tf", num(x), num(baseline), "Td", escapeString(encoded), "Tj", "ET")
	return nil
}

func (p *Page) rect(x, y, w, h float64) {
	p.op(num(x), num(PageHeight-y-h), num(w), num(h), "re")
}

// StrokeRect draws the outline of a rectangle with corner radius r. x and y are the top-left corner.
func (p *Page) StrokeRect(x, y, w, h, r, lineWidth float64, c Color) {
	p.setStroke(c, lineWidth)
	bottom := PageHeight - y - h
	if r <= 0 {
		p.op(num(x), num(bottom), num(w), num(h), "re", "S")
		return
	}
	// Control point distance of a cubic Bezier quarter circle.
	k := r * 0.5522847498
	left, right, top := x, x+w, bottom+h
	p.op(num(left), num(bottom+r), "m")
	p.op(num(left), num(bottom+r-k), num(left+r-k), num(bottom), num(left+r), num(bottom), "c")
	p.op(num(right-r), num(bottom), "l")
	p.op(num(right-r+k), num(bottom), num(right), num(bottom+r-k), num(right), num(bottom+r), "c")
	p.op(num(right), num(top-r), "l")
	p.op(num(right), num(top-r+k), num(right-r+k), num(top), num(right-r), num(top), "c")
	p.op(num(left+r), num(top), "l")
	p.op(num(left+r-k), num(top), num(left), num(top-r+k), num(left), num(top-r), "c")
	p.op("h", "S")
}

func fontName(f Font) string {
	if f == HelveticaBold {
		return "/F2"
	}
	return "/F1"
}

func escapeString(b []byte) string {
	var out bytes.Buffer
	out.WriteByte('(')
	for _, c := range b {
		if c == '(' || c == ')' || c == '\\' {
			out.WriteByte('\\')
		}
		out.WriteByte(c)
	}
	out.WriteByte(')')
	return out.String()
}

// Bytes returns the serialized PDF file.
func (d *Document) Bytes() ([]byte, error) {
	if len(d.pages) == 0 {
		return nil, errors.New("document has no pages")
	}

	const fontObjects = 2
	pagesID := 2
	firstPageID := 3 + fontObjects

	var objects [][]byte
	objects = append(objects, []byte("<< /Type /Catalog /Pages 2 0 R >>"))

	var kids bytes.Buffer
	for i := range d.pages {
		if i > 0 {
			kids.WriteByte(' ')
		}
		fmt.Fprintf(&kids, "%d 0 R", firstPageID+2*i)
	}
	objects = append(objects, fmt.Appendf(nil, "<< /Type /Pages /Kids [%s] /Count %d >>", kids.String(), len(d.pages)))
	objects = append(objects,
		[]byte("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>"),
		[]byte("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>"),
	)

	for i, p := range d.pages {
		contentID := firstPageID + 2*i + 1
		objects = append(objects, fmt.Appendf(nil,
			"<< /Type /Page /Parent %d 0 R /MediaBox [0 0 %s %s] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents %d 0 R >>",
			pagesID, num(PageWidth), num(PageHeight), contentID))
		stream := p.content.Bytes()
		obj := fmt.Appendf(nil, "<< /Length %d >>\nstream\n", len(stream))
		obj = append(obj, stream...)
		obj = append(obj, "endstream"...)
		objects = append(objects, obj)
	}

	var out bytes.Buffer
	out.WriteString("%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
	offsets := make([]int, len(objects))
	for i, obj := range objects {
		offsets[i] = out.Len()
		fmt.Fprintf(&out, "%d 0 obj\n", i+1)
		out.Write(obj)
		out.WriteString("\nendobj\n")
	}

	xref := out.Len()
	fmt.Fprintf(&out, "xref\n0 %d\n", len(objects)+1)
	out.WriteString("0000000000 65535 f \n")
	for _, off := range offsets {
		fmt.Fprintf(&out, "%010d 00000 n \n", off)
	}
	fmt.Fprintf(&out, "trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n", len(objects)+1, xref)
	return out.Bytes(), nil
}
