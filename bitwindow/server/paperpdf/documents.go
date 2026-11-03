package paperpdf

import (
	"fmt"
)

const (
	pageMargin   = 40.0
	contentWidth = PageWidth - 2*pageMargin
	contentBot   = PageHeight - pageMargin
	panelGap     = 30.0
	panelWidth   = (contentWidth - panelGap) / 2
	qrSide       = 200.0
)

var (
	blue   = Color{0x21 / 255.0, 0x96 / 255.0, 0xF3 / 255.0}
	red    = Color{0xF4 / 255.0, 0x43 / 255.0, 0x36 / 255.0}
	orange = Color{1, 0x98 / 255.0, 0}
)

func centered(font Font, pt float64, value string) text {
	return text{font: font, pt: pt, align: AlignCenter, color: Black, value: value}
}

func left(font Font, pt float64, value string) text {
	return text{font: font, pt: pt, align: AlignLeft, color: Black, value: value}
}

func drawBlock(p *Page, x, y, w float64, b block) (bottom float64, err error) {
	_, h := b.size(w)
	if err := b.draw(p, x, y, w); err != nil {
		return 0, err
	}
	return y + h, nil
}

// PaperWallet is the data of a paper wallet document.
type PaperWallet struct {
	Address   string
	WIF       string
	AddressQR QRMatrix
	WIFQR     QRMatrix
}

// PaperWalletPDF returns the paper wallet as a one-page PDF.
func PaperWalletPDF(w PaperWallet) ([]byte, error) {
	var doc Document
	p := doc.AddPage()

	header := column{align: AlignCenter, items: []block{
		centered(HelveticaBold, 32, "BITCOIN PAPER WALLET"),
		gap(10),
		centered(Helvetica, 12, "Keep this paper wallet in a secure location"),
	}}
	headerBottom, err := drawBlock(p, pageMargin, pageMargin, contentWidth, header)
	if err != nil {
		return nil, err
	}

	footer := box{padding: 10, lineWidth: 2, radius: 5, color: Black, child: centered(Helvetica, 9,
		"SECURITY WARNING: Generate paper wallets on an offline computer. Store printed wallet in a secure location. "+
			"Never share your private key. Anyone with access to the private key can spend all funds.")}
	footerWidth, footerHeight := footer.size(contentWidth)
	footerTop := contentBot - footerHeight
	if err := footer.draw(p, pageMargin+(contentWidth-footerWidth)/2, footerTop, footerWidth); err != nil {
		return nil, err
	}

	panels := []column{
		{align: AlignCenter, items: []block{
			centered(HelveticaBold, 24, "LOAD & VERIFY"),
			gap(5),
			centered(Helvetica, 14, "Public Bitcoin Address"),
			gap(20),
			qr{side: qrSide, matrix: w.AddressQR},
			gap(15),
			centered(HelveticaBold, 10, w.Address),
			gap(15),
			centered(Helvetica, 10, "Share this address to receive Bitcoin"),
		}},
		{align: AlignCenter, items: []block{
			centered(HelveticaBold, 24, "SPEND"),
			gap(5),
			centered(Helvetica, 14, "Private Key (WIF)"),
			gap(20),
			qr{side: qrSide, matrix: w.WIFQR},
			gap(15),
			centered(HelveticaBold, 10, w.WIF),
			gap(15),
			box{padding: 8, lineWidth: 2, radius: 5, color: Black, child: centered(HelveticaBold, 10,
				"KEEP SECRET: Anyone with this private key can spend your Bitcoin")},
		}},
	}
	const panelPadding = 20.0
	innerWidth := panelWidth - 2*panelPadding
	var contentHeight float64
	for _, panel := range panels {
		_, h := panel.size(innerWidth)
		contentHeight = max(contentHeight, h)
	}
	free := footerTop - 20 - headerBottom - (contentHeight + 2*panelPadding)
	if free < 0 {
		return nil, fmt.Errorf("paper wallet is %.1f pt too high for the page", -free)
	}
	panelsTop := headerBottom + min(30, free)
	panelHeight := footerTop - 20 - panelsTop

	for i, panel := range panels {
		x := pageMargin + float64(i)*(panelWidth+panelGap)
		p.StrokeRect(x, panelsTop, panelWidth, panelHeight, 10, 3, Black)
		_, h := panel.size(innerWidth)
		if err := panel.draw(p, x+panelPadding, panelsTop+panelPadding+(panelHeight-2*panelPadding-h)/2, innerWidth); err != nil {
			return nil, err
		}
	}

	return doc.Bytes()
}

// PaperCheck is the data of a paper check document.
type PaperCheck struct {
	// Amount is the amount with its unit, for example "0.001 BTC".
	Amount    string
	Address   string
	WIF       string
	TxID      string
	AddressQR QRMatrix
	WIFQR     QRMatrix
}

// PaperCheckPDF returns the paper check as a one-page PDF.
func PaperCheckPDF(c PaperCheck) ([]byte, error) {
	var doc Document
	p := doc.AddPage()

	panel := func(color Color, title, label string, matrix QRMatrix, value string, note text) box {
		return box{padding: 20, lineWidth: 3, color: color, child: column{align: AlignCenter, items: []block{
			centered(HelveticaBold, 20, title),
			gap(5),
			centered(Helvetica, 12, label),
			gap(15),
			qr{side: qrSide, matrix: matrix},
			gap(15),
			centered(Helvetica, 9, value),
			gap(10),
			note,
		}}}
	}
	redNote := centered(Helvetica, 10, "Recipient needs this key to redeem")
	redNote.color = red
	panels := []box{
		panel(blue, "RECIPIENT", "Bitcoin Address", c.AddressQR, c.Address, centered(Helvetica, 10, "Give this check to the recipient")),
		panel(red, "REDEEM", "Private Key (WIF)", c.WIFQR, c.WIF, redNote),
	}

	// The bullet lines have the spacing of the lines of one wrapped text.
	bulletGap := gap((linePitch - lineHeight) * 10)
	warnings := box{padding: 15, lineWidth: 2, color: orange, child: column{align: AlignLeft, items: []block{
		left(HelveticaBold, 14, "SECURITY WARNINGS"),
		gap(8),
		left(Helvetica, 10, "• Anyone with the private key can spend these funds"),
		bulletGap,
		left(Helvetica, 10, "• Store this check in a secure location"),
		bulletGap,
		left(Helvetica, 10, "• Do not share the private key except with the intended recipient"),
		gap(8),
		left(Helvetica, 8, "Transaction ID: "+c.TxID),
	}}}
	page := func(sectionGap float64) column {
		return column{align: AlignCenter, items: []block{
			centered(HelveticaBold, 32, "BITCOIN PAPER CHECK"),
			gap(10),
			centered(HelveticaBold, 24, "Amount: "+c.Amount),
			gap(sectionGap),
			panelRow{panels: panels},
			gap(sectionGap),
			warnings,
		}}
	}
	_, h := page(0).size(contentWidth)
	free := contentBot - pageMargin - h
	if free < 0 {
		return nil, fmt.Errorf("paper check is %.1f pt too high for the page", -free)
	}
	if _, err := drawBlock(p, pageMargin, pageMargin, contentWidth, page(min(30, free/2))); err != nil {
		return nil, err
	}

	return doc.Bytes()
}

// panelRow puts two panels of equal width side by side, with the height of the highest panel.
type panelRow struct {
	panels []box
}

func (r panelRow) size(maxWidth float64) (w, h float64) {
	for _, panel := range r.panels {
		_, ph := panel.size(panelWidth)
		h = max(h, ph)
	}
	return maxWidth, h
}

func (r panelRow) draw(p *Page, x, y, w float64) error {
	_, h := r.size(w)
	for i, panel := range r.panels {
		px := x + float64(i)*(panelWidth+panelGap)
		p.StrokeRect(px, y, panelWidth, h, 0, panel.lineWidth, panel.color)
		if err := panel.child.draw(p, px+panel.padding, y+panel.padding, panelWidth-2*panel.padding); err != nil {
			return err
		}
	}
	return nil
}
