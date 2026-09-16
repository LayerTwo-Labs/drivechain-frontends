package main

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestParseCatalogURL(t *testing.T) {
	for _, test := range []struct {
		name  string
		raw   string
		want  string
		error string
	}{
		{name: "empty keeps the default", raw: ""},
		{name: "http", raw: "http://localhost:8899/config", want: "http://localhost:8899/config"},
		{name: "https", raw: "https://drivechain.dev/config", want: "https://drivechain.dev/config"},
		{name: "file scheme", raw: "file:///tmp/config.json", error: "http or https"},
		{name: "no scheme", raw: "localhost:8899/config", error: "http or https"},
		{name: "no host", raw: "http:///config", error: "must name a host"},
		{name: "control character", raw: "http://local\x7fhost/config", error: "parse --catalog-url"},
	} {
		t.Run(test.name, func(t *testing.T) {
			got, err := parseCatalogURL(test.raw)
			if test.error != "" {
				require.ErrorContains(t, err, test.error)
				require.Empty(t, got)
				return
			}
			require.NoError(t, err)
			require.Equal(t, test.want, got)
		})
	}
}
