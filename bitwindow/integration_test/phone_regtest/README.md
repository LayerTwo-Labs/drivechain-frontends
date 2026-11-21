# Phone regtest test

`integration_test/phone_regtest_test.dart` drives BitWindow on a phone through
the hot paths: first start, new wallet, receive, send, confirm, UTXOs, side nav,
bump fee and cancel. The phone runs light mode against a regtest stack on the Mac.

1. Start the stack. It runs Bitcoin Core, the enforcer and an Esplora server
   with test routes:

   ```sh
   cd bitwindow
   ENFORCER_BIN=<path to bip300301_enforcer> scripts/phone-regtest.sh start
   ```

2. Build the backend library for regtest:

   ```sh
   BITWINDOW_DEFAULT_NETWORK=regtest just ios-backend      # or android-backend
   ```

3. Remove the app from the device, so the test starts with no wallet.

4. Run the test. iOS reaches the Mac at 127.0.0.1, so give a port offset that
   no other BitWindow uses. Android reaches it at 10.0.2.2:

   ```sh
   PHONE_QA_SHOTS=/tmp/phone-qa/ios flutter drive -d <simulator> \
     --driver test_driver/phone_regtest_driver.dart \
     --target integration_test/phone_regtest_test.dart \
     --dart-define=BITWINDOW_PORT_OFFSET=5200 $(scripts/phone-regtest.sh defines ios)

   PHONE_QA_SHOTS=/tmp/phone-qa/android flutter drive -d <emulator> \
     --driver test_driver/phone_regtest_driver.dart \
     --target integration_test/phone_regtest_test.dart \
     $(scripts/phone-regtest.sh defines android)
   ```

`integration_test/phone_menus_test.dart` opens and closes every side nav item.
Run it the same way, with `--target integration_test/phone_menus_test.dart`.

The tests fail on a layout overflow that is not in their list of known faults, and write one screenshot per step to
`PHONE_QA_SHOTS`. Run one device at a time: the test counts the regtest mempool.
