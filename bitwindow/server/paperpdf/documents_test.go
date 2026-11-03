package paperpdf

import (
	"regexp"
	"strconv"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	testAddress = "mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn"
	testWIF     = "cVt4o7BGAig1UXywgGSmARhxMdzP5qvQsxKkSsc1XEkw3tDTQFpy"
	testTxID    = "f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16"
)

type textOp struct {
	font string
	size float64
	text string
}

var textPattern = regexp.MustCompile(`(?m)^BT /(F\d) (\S+) Tf (\S+) (\S+) Td \((.*)\) Tj ET$`)

// textOps returns the text lines of a page in draw order, and fails when a line is outside the page margins.
func textOps(t *testing.T, content string) []textOp {
	t.Helper()
	var ops []textOp
	for _, m := range textPattern.FindAllStringSubmatch(content, -1) {
		size, err := strconv.ParseFloat(m[2], 64)
		require.NoError(t, err)
		x, err := strconv.ParseFloat(m[3], 64)
		require.NoError(t, err)
		baseline, err := strconv.ParseFloat(m[4], 64)
		require.NoError(t, err)
		text := strings.NewReplacer(`\(`, "(", `\)`, ")", `\\`, `\`, "\x95", "•").Replace(m[5])
		font := Helvetica
		if m[1] == "F2" {
			font = HelveticaBold
		}
		assert.GreaterOrEqual(t, x, pageMargin, "left edge of %q", text)
		assert.LessOrEqual(t, x+TextWidth(font, size, text), PageWidth-pageMargin+0.01, "right edge of %q", text)
		assert.LessOrEqual(t, PageHeight-baseline-ascent*size, PageHeight-pageMargin, "top of %q", text)
		assert.GreaterOrEqual(t, baseline-descent*size, pageMargin-0.01, "bottom of %q", text)
		ops = append(ops, textOp{font: m[1], size: size, text: text})
	}
	return ops
}

func darkModules(f qrFixture) int {
	n := 0
	for _, row := range f.Rows {
		n += strings.Count(row, "#")
	}
	return n
}

func TestPaperWalletPDF(t *testing.T) {
	f, m := loadFixture(t)
	b, err := PaperWalletPDF(PaperWallet{Address: testAddress, WIF: testWIF, AddressQR: m, WIFQR: m})
	require.NoError(t, err)

	streams := parsePDF(t, b)
	require.Len(t, streams, 1)
	content := streams[0]

	assert.Equal(t, []textOp{
		{"F2", 32, "BITCOIN PAPER WALLET"},
		{"F1", 12, "Keep this paper wallet in a secure location"},
		{"F1", 9, "SECURITY WARNING: Generate paper wallets on an offline computer. Store printed wallet in a secure location. " +
			"Never share your private key. Anyone with access to the private key can"},
		{"F1", 9, "spend all funds."},
		{"F2", 24, "LOAD & VERIFY"},
		{"F1", 14, "Public Bitcoin Address"},
		{"F2", 10, testAddress},
		{"F1", 10, "Share this address to receive Bitcoin"},
		{"F2", 24, "SPEND"},
		{"F1", 14, "Private Key (WIF)"},
		{"F2", 10, testWIF},
		{"F2", 10, "KEEP SECRET: Anyone with this private key can spend your"},
		{"F2", 10, "Bitcoin"},
	}, textOps(t, content))

	assert.Equal(t, 2*darkModules(f), strings.Count(content, " re\n"))
	assert.Equal(t, 4, strings.Count(content, "h S\n"), "the footer, two panels and the secret box have round corners")
}

func TestPaperWalletPDFTooHigh(t *testing.T) {
	_, m := loadFixture(t)
	_, err := PaperWalletPDF(PaperWallet{Address: testAddress, WIF: strings.Repeat(testWIF, 30), AddressQR: m, WIFQR: m})
	require.ErrorContains(t, err, "too high for the page")
}

func TestPaperWalletPDFBadQR(t *testing.T) {
	_, m := loadFixture(t)
	_, err := PaperWalletPDF(PaperWallet{Address: testAddress, WIF: testWIF, AddressQR: m, WIFQR: QRMatrix{Size: 21}})
	require.ErrorContains(t, err, "QR has 0 modules")
}

func TestPaperCheckPDF(t *testing.T) {
	f, m := loadFixture(t)
	b, err := PaperCheckPDF(PaperCheck{Amount: "0.001 BTC", Address: testAddress, WIF: testWIF, TxID: testTxID, AddressQR: m, WIFQR: m})
	require.NoError(t, err)

	streams := parsePDF(t, b)
	require.Len(t, streams, 1)
	content := streams[0]

	assert.Equal(t, []textOp{
		{"F2", 32, "BITCOIN PAPER CHECK"},
		{"F2", 24, "Amount: 0.001 BTC"},
		{"F2", 20, "RECIPIENT"},
		{"F1", 12, "Bitcoin Address"},
		{"F1", 9, testAddress},
		{"F1", 10, "Give this check to the recipient"},
		{"F2", 20, "REDEEM"},
		{"F1", 12, "Private Key (WIF)"},
		{"F1", 9, testWIF},
		{"F1", 10, "Recipient needs this key to redeem"},
		{"F2", 14, "SECURITY WARNINGS"},
		{"F1", 10, "• Anyone with the private key can spend these funds"},
		{"F1", 10, "• Store this check in a secure location"},
		{"F1", 10, "• Do not share the private key except with the intended recipient"},
		{"F1", 8, "Transaction ID: " + testTxID},
	}, textOps(t, content))

	assert.Equal(t, 2*darkModules(f), strings.Count(content, " re\n"))
	assert.Equal(t, 3, strings.Count(content, " re S\n"), "the two panels and the warnings box have square corners")
	assert.Contains(t, content, "0.129 0.588 0.953 RG 3 w", "blue recipient border")
	assert.Contains(t, content, "0.957 0.263 0.212 RG 3 w", "red redeem border")
	assert.Contains(t, content, "1 0.596 0 RG 2 w", "orange warnings border")
	assert.Contains(t, content, "0.957 0.263 0.212 rg\nBT /F1 10 Tf", "red redeem note")
}

func TestPaperWalletPDFWideWIFFits(t *testing.T) {
	_, m := loadFixture(t)
	wif := "cW" + strings.Repeat("W", 50)
	b, err := PaperWalletPDF(PaperWallet{Address: testAddress, WIF: wif, AddressQR: m, WIFQR: m})
	require.NoError(t, err)

	ops := textOps(t, parsePDF(t, b)[0])
	assert.Equal(t, wif, ops[10].text+ops[11].text, "the WIF wraps to two lines")
}
