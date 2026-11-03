package paperpdf

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type qrFixture struct {
	Data    string   `json:"data"`
	Size    int      `json:"size"`
	Modules string   `json:"modules"`
	Rows    []string `json:"rows"`
}

func loadFixture(t *testing.T) (qrFixture, QRMatrix) {
	t.Helper()
	raw, err := os.ReadFile("testdata/qr_fixture.json")
	require.NoError(t, err)
	var f qrFixture
	require.NoError(t, json.Unmarshal(raw, &f))
	modules, err := base64.StdEncoding.DecodeString(f.Modules)
	require.NoError(t, err)
	return f, QRMatrix{Size: f.Size, Modules: modules}
}

var objectHeader = regexp.MustCompile(`(?m)^(\d+) 0 obj\n`)

// parsePDF checks the xref table, the trailer and the stream lengths, and returns the page content streams.
func parsePDF(t *testing.T, b []byte) []string {
	t.Helper()
	require.True(t, bytes.HasPrefix(b, []byte("%PDF-1.4\n")))
	require.True(t, bytes.HasSuffix(b, []byte("\n%%EOF\n")))

	tail := b[bytes.LastIndex(b, []byte("startxref\n")):]
	var xrefOffset int
	_, err := fmt.Sscanf(string(tail), "startxref\n%d\n", &xrefOffset)
	require.NoError(t, err)
	require.True(t, bytes.HasPrefix(b[xrefOffset:], []byte("xref\n")), "startxref does not point at the xref table")

	lines := strings.Split(string(b[xrefOffset:]), "\n")
	var first, count int
	_, err = fmt.Sscanf(lines[1], "%d %d", &first, &count)
	require.NoError(t, err)
	require.Equal(t, 0, first)
	require.Equal(t, "0000000000 65535 f ", lines[2])

	headers := objectHeader.FindAllSubmatchIndex(b, -1)
	require.Len(t, headers, count-1)
	for i, h := range headers {
		id, err := strconv.Atoi(string(b[h[2]:h[3]]))
		require.NoError(t, err)
		require.Equal(t, i+1, id)
		assert.Equal(t, fmt.Sprintf("%010d 00000 n ", h[0]), lines[3+i], "xref entry of object %d", id)
	}
	require.Equal(t, "trailer", lines[3+len(headers)])
	assert.Equal(t, fmt.Sprintf("<< /Size %d /Root 1 0 R >>", count), lines[4+len(headers)])

	var streams []string
	for _, m := range regexp.MustCompile(`<< /Length (\d+) >>\nstream\n`).FindAllSubmatchIndex(b, -1) {
		length, err := strconv.Atoi(string(b[m[2]:m[3]]))
		require.NoError(t, err)
		start := m[1]
		require.True(t, bytes.HasPrefix(b[start+length:], []byte("endstream\nendobj\n")), "stream length is wrong")
		streams = append(streams, string(b[start:start+length]))
	}
	return streams
}

func TestDocumentStructure(t *testing.T) {
	var doc Document
	require.NoError(t, doc.AddPage().Text(10, 10, Helvetica, 12, AlignLeft, Black, "one"))
	require.NoError(t, doc.AddPage().Text(10, 10, HelveticaBold, 12, AlignLeft, Black, "two"))
	b, err := doc.Bytes()
	require.NoError(t, err)

	streams := parsePDF(t, b)
	require.Len(t, streams, 2)
	assert.Contains(t, streams[0], "/F1 12 Tf")
	assert.Contains(t, streams[1], "/F2 12 Tf")
	assert.Contains(t, string(b), "/Kids [5 0 R 7 0 R] /Count 2")
	assert.Contains(t, string(b), "/BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding")
	assert.Contains(t, string(b), "/MediaBox [0 0 841.89 595.276]")
}

func TestDocumentWithoutPages(t *testing.T) {
	var doc Document
	_, err := doc.Bytes()
	require.ErrorContains(t, err, "no pages")
}

func TestTextEscape(t *testing.T) {
	var p Page
	require.NoError(t, p.Text(0, 0, Helvetica, 10, AlignLeft, Black, `a(b)c\d`))
	assert.Contains(t, p.content.String(), `(a\(b\)c\\d) Tj`)
}

func TestTextBullet(t *testing.T) {
	var p Page
	require.NoError(t, p.Text(0, 0, Helvetica, 10, AlignLeft, Black, "• x"))
	assert.Contains(t, p.content.String(), "(\x95 x) Tj")
}

func TestTextOutsideWinAnsi(t *testing.T) {
	var p Page
	err := p.Text(0, 0, Helvetica, 10, AlignLeft, Black, "kr ø")
	require.ErrorContains(t, err, "U+00F8")
}

func TestTextCenter(t *testing.T) {
	var p Page
	require.NoError(t, p.Text(100, 0, Helvetica, 10, AlignCenter, Black, "AA"))
	// Two A glyphs of 667/1000 at 10 pt are 13.34 pt wide.
	assert.Contains(t, p.content.String(), "/F1 10 Tf 93.33 ")
}

func TestWrap(t *testing.T) {
	assert.Equal(t, []string{"aaa bbb", "ccc"}, Wrap(Helvetica, 10, TextWidth(Helvetica, 10, "aaa bbb"), "aaa bbb ccc"))
	assert.Equal(t, []string{"1111", "1111", "11"}, Wrap(Helvetica, 10, TextWidth(Helvetica, 10, "1111"), "1111111111"))
	assert.Equal(t, []string{"short"}, Wrap(HelveticaBold, 10, 500, "short"))
}

func TestQRDrawsOneRectPerDarkModule(t *testing.T) {
	f, m := loadFixture(t)
	var p Page
	require.NoError(t, p.QR(100, 50, 210, m))

	var dark [][2]int
	for row, line := range f.Rows {
		for col, c := range line {
			if c == '#' {
				dark = append(dark, [2]int{row, col})
			}
		}
	}

	rects := regexp.MustCompile(`(?m)^(\S+) (\S+) 10 10 re$`).FindAllStringSubmatch(p.content.String(), -1)
	require.Len(t, rects, len(dark))
	for i, cell := range dark {
		assert.Equal(t, num(100+float64(cell[1])*10), rects[i][1], "x of module %v", cell)
		assert.Equal(t, num(PageHeight-50-float64(cell[0]+1)*10), rects[i][2], "y of module %v", cell)
	}
	assert.Equal(t, 1, strings.Count(p.content.String(), "\nf\n"))
}

func TestQRValidate(t *testing.T) {
	_, valid := loadFixture(t)
	require.NoError(t, valid.Validate())

	for name, m := range map[string]QRMatrix{
		"size is not a QR version": {Size: 22, Modules: make([]byte, 22*22)},
		"too few modules":          {Size: 21, Modules: make([]byte, 20)},
		"module is not 0 or 1":     {Size: 21, Modules: append(make([]byte, 21*21-1), 2)},
	} {
		t.Run(name, func(t *testing.T) {
			var p Page
			require.ErrorContains(t, p.QR(0, 0, 200, m), "QR")
		})
	}
}
