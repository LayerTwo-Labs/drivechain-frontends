double satoshiToBTC(int sats) {
  const int satoshiPerBitcoin = 100000000;
  return sats / satoshiPerBitcoin;
}
