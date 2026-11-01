package wallet

import (
	"errors"
	"strings"
	"unicode"
)

// JoinDescriptorPair reads text that holds one descriptor, or a receive (/0/*)
// and change (/1/*) pair with optional "External:" style labels. It returns
// the one descriptor that derives both chains.
func JoinDescriptorPair(text string) (string, error) {
	descriptors := descriptorTokens(text)
	switch len(descriptors) {
	case 0:
		return strings.TrimSpace(text), nil
	case 1:
		return descriptors[0], nil
	case 2:
	default:
		return "", errors.New("paste one descriptor, or one receive and one change descriptor")
	}

	receive, err := stripDescriptorChecksum(descriptors[0])
	if err != nil {
		return "", err
	}
	change, err := stripDescriptorChecksum(descriptors[1])
	if err != nil {
		return "", err
	}
	if strings.Contains(withoutSpace(receive), "/1/*") {
		receive, change = change, receive
	}
	receive, change = withoutSpace(receive), withoutSpace(change)
	if !strings.Contains(receive, "/0/*") || strings.ReplaceAll(receive, "/0/*", "/1/*") != change {
		return "", errors.New("the two descriptors must be the receive (/0/*) and change (/1/*) descriptors of one wallet")
	}
	return receive, nil
}

// descriptorTokens returns each script descriptor in text, without labels.
// Whitespace inside the parentheses stays part of the descriptor.
func descriptorTokens(text string) []string {
	var out []string
	for _, field := range topLevelFields(text) {
		open := strings.Index(field, "(")
		if open < 0 {
			continue
		}
		if colon := strings.Index(field, ":"); colon >= 0 && colon < open {
			field = field[colon+1:]
		}
		out = append(out, field)
	}
	return out
}

func topLevelFields(text string) []string {
	var fields []string
	var field strings.Builder
	depth := 0
	for _, r := range text {
		switch {
		case r == '(':
			depth++
		case r == ')' && depth > 0:
			depth--
		case unicode.IsSpace(r) && depth == 0:
			if field.Len() > 0 {
				fields = append(fields, field.String())
				field.Reset()
			}
			continue
		}
		field.WriteRune(r)
	}
	if field.Len() > 0 {
		fields = append(fields, field.String())
	}
	return fields
}

func withoutSpace(s string) string {
	return strings.Join(strings.Fields(s), "")
}
