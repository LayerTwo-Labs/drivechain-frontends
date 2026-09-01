package orchestrator

import "testing"

func TestHighestFeeRate(t *testing.T) {
	tests := []struct {
		name  string
		rates []float64
		want  float64
	}{
		{name: "the estimate wins over the relay floor", rates: []float64{12.5, 1}, want: 12.5},
		{name: "a raised relay floor wins over the estimate", rates: []float64{0.3, 5}, want: 5},
		{name: "no estimate leaves the relay floor", rates: []float64{0, 3}, want: 3},
		{name: "no relay floor leaves the estimate", rates: []float64{7, 0}, want: 7},
		{name: "neither answers", rates: []float64{0, 0}, want: 0},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := highestFeeRate(test.rates...); got != test.want {
				t.Fatalf("highestFeeRate(%v) = %v, want %v", test.rates, got, test.want)
			}
		})
	}
}
