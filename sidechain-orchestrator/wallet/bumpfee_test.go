package wallet

import "testing"

func TestMinBumpFeeRate(t *testing.T) {
	if got := minBumpFeeRate(200, 200, 0); got != 2 {
		t.Fatalf("min rate = %d, want 2", got)
	}
	if got := minBumpFeeRate(0, 200, 0); got != 1 {
		t.Fatalf("min rate = %d, want 1", got)
	}
	if got := minBumpFeeRate(250, 200, 0); got != 3 {
		t.Fatalf("min rate = %d, want 3", got)
	}
}

// A replacement carries new signatures, so it can grow by a byte per input. The
// floor covers that growth, or the node rejects the replacement.
func TestMinBumpFeeRateCoversASignatureThatGrows(t *testing.T) {
	plain := minBumpFeeRate(200, 200, 0)
	padded := minBumpFeeRate(200, 200, 20)
	if padded <= plain {
		t.Fatalf("floor with 20 inputs = %d, want more than %d", padded, plain)
	}
	// The floor must still pay the relay increment for the largest replacement.
	if padded*200 < 200+replacementVsize(200, 20) {
		t.Fatalf("floor %d sat/vB pays %d sats, under the relay increment", padded, padded*200)
	}
}

func TestPlanBumpFeeTakesFromChange(t *testing.T) {
	change := BumpFeeOutput{Vout: 1, AmountSats: 10000, IsChange: true, DustSats: 294}
	plan, err := planBumpFee(bumpFeeTx{OldFeeSats: 200, VsizeBytes: 200, InputCount: 1, OutputCount: 2}, 8, change)
	if err != nil {
		t.Fatalf("plan: %v", err)
	}
	if plan.NewFeeSats != 1600 {
		t.Fatalf("new fee = %d, want 1600", plan.NewFeeSats)
	}
	if plan.ExtraFeeSats != 1400 {
		t.Fatalf("extra = %d, want 1400", plan.ExtraFeeSats)
	}
	if plan.AmountAfter != 8600 {
		t.Fatalf("amount after = %d, want 8600", plan.AmountAfter)
	}
	if plan.OutputRemoved {
		t.Fatal("plan removes an output that stays above dust")
	}
	if plan.ReducesPayment {
		t.Fatal("plan reduces a payment, but it takes the fee from change")
	}
	if plan.NewFeeRate != 8 {
		t.Fatalf("new rate = %v, want 8", plan.NewFeeRate)
	}
}

func TestPlanBumpFeeRefusesRateBelowMinimum(t *testing.T) {
	change := BumpFeeOutput{Vout: 1, AmountSats: 10000, IsChange: true, DustSats: 294}
	if _, err := planBumpFee(bumpFeeTx{OldFeeSats: 200, VsizeBytes: 200, InputCount: 1, OutputCount: 2}, 1, change); err == nil {
		t.Fatal("plan accepts a fee rate that does not replace the transaction")
	}
}

func TestPlanBumpFeeDropsDustChange(t *testing.T) {
	change := BumpFeeOutput{Vout: 1, AmountSats: 1500, IsChange: true, DustSats: 294}
	plan, err := planBumpFee(bumpFeeTx{OldFeeSats: 200, VsizeBytes: 200, InputCount: 1, OutputCount: 2}, 8, change)
	if err != nil {
		t.Fatalf("plan: %v", err)
	}
	if !plan.OutputRemoved {
		t.Fatal("plan keeps a change output that falls under the dust limit")
	}
	if plan.AmountAfter != 0 {
		t.Fatalf("amount after = %d, want 0", plan.AmountAfter)
	}
	if plan.NewFeeSats != 1700 {
		t.Fatalf("new fee = %d, want 1700", plan.NewFeeSats)
	}
	if plan.ExtraFeeSats != 1500 {
		t.Fatalf("extra = %d, want 1500", plan.ExtraFeeSats)
	}
}

func TestPlanBumpFeeRefusesOutputThatCannotPay(t *testing.T) {
	change := BumpFeeOutput{Vout: 1, AmountSats: 1000, IsChange: true, DustSats: 294}
	if _, err := planBumpFee(bumpFeeTx{OldFeeSats: 200, VsizeBytes: 200, InputCount: 1, OutputCount: 2}, 8, change); err == nil {
		t.Fatal("plan accepts an output that cannot pay the higher fee")
	}
}

func TestPlanBumpFeeMarksReducedPayment(t *testing.T) {
	payment := BumpFeeOutput{Vout: 0, AmountSats: 20000, DustSats: 294}
	plan, err := planBumpFee(bumpFeeTx{OldFeeSats: 200, VsizeBytes: 200, InputCount: 1, OutputCount: 2}, 8, payment)
	if err != nil {
		t.Fatalf("plan: %v", err)
	}
	if !plan.ReducesPayment {
		t.Fatal("plan takes the fee from a payment, but does not mark it")
	}
	if plan.AmountAfter != 18600 {
		t.Fatalf("amount after = %d, want 18600", plan.AmountAfter)
	}
}

func TestPickBumpFeeOutput(t *testing.T) {
	outputs := []BumpFeeOutput{
		{Vout: 0, AmountSats: 20000, Address: "tb1qpayment"},
		{Vout: 1, AmountSats: 10000, Address: "tb1qchange", IsChange: true},
	}
	target, err := pickBumpFeeOutput(outputs, nil)
	if err != nil {
		t.Fatalf("pick: %v", err)
	}
	if target.Vout != 1 {
		t.Fatalf("pick = %d, want the change output at 1", target.Vout)
	}

	vout := 0
	target, err = pickBumpFeeOutput(outputs, &vout)
	if err != nil {
		t.Fatalf("pick: %v", err)
	}
	if target.Vout != 0 {
		t.Fatalf("pick = %d, want 0", target.Vout)
	}

	missing := 7
	if _, err := pickBumpFeeOutput(outputs, &missing); err == nil {
		t.Fatal("pick accepts an output the transaction does not hold")
	}

	if _, err := pickBumpFeeOutput(outputs[:1], nil); err == nil {
		t.Fatal("pick finds a change output in a transaction that has none")
	}

	opReturn := []BumpFeeOutput{{Vout: 0, AmountSats: 0}}
	zero := 0
	if _, err := pickBumpFeeOutput(opReturn, &zero); err == nil {
		t.Fatal("pick accepts an output with no address")
	}
}
