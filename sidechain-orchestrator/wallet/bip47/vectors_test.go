package bip47

// Test vectors from https://gist.github.com/SamouraiDev/6aad669604c5930864bd

const (
	aliceMnemonic            = "response seminar brave tip suit recall often sound stick owner lottery motion"
	aliceSeedHex             = "64dca76abc9c6f0cf3d212d248c380c4622c8f93b2c425ec6a5567fd5db57e10d3e6f94a2f6af4ac2edb8998072aad92098db73558c323777abf5bd1082d970a"
	alicePaymentCode         = "PM8TJTLJbPRGxSbc8EJi42Wrr6QbNSaSSVJ5Y3E4pbCYiTHUskHg13935Ubb7q8tx9GVbh2UuRnBc3WSyJHhUrw8KhprKnn9eDznYGieTzFcwQRya4GA"
	aliceNotificationAddress = "1JDdmqFLhpzcUwPeinhJbUPw4Co3aWLyzW"
	aliceA0Hex               = "8d6a8ecd8ee5e0042ad0cb56e3a971c760b5145c3917a8e7beaf0ed92d7a520c"
	aliceA0PubHex            = "0353883a146a23f988e0f381a9507cbdb3e3130cd81b3ce26daf2af088724ce683"

	bobMnemonic            = "reward upper indicate eight swift arch injury crystal super wrestle already dentist"
	bobSeedHex             = "87eaaac5a539ab028df44d9110defbef3797ddb805ca309f61a69ff96dbaa7ab5b24038cf029edec5235d933110f0aea8aeecf939ed14fc20730bba71e4b1110"
	bobPaymentCode         = "PM8TJS2JxQ5ztXUpBBRnpTbcUXbUHy2T1abfrb3KkAAtMEGNbey4oumH7Hc578WgQJhPjBxteQ5GHHToTYHE3A1w6p7tU6KSoFmWBVbFGjKPisZDbP97"
	bobNotificationAddress = "1ChvUUvht2hUQufHBXF8NgLhW8SwE2ecGV"
	bobB0PubHex            = "024ce8e3b04ea205ff49f529950616c3db615b1e37753858cc60c1ce64d17e2ad8"

	// Notification tx Alice → Bob.
	designatedOutpointHex = "86f411ab1c8e70ae8a0795ab7a6757aea6e4d5ae1826fc7b8f00c597d500609c01000000"
	designatedInputWIF    = "Kx983SRhAZpAhj7Aac1wUXMJ6XZeyJKqCxJJ49dxEbYCT4a1ozRD"
	sharedSecretXHex      = "736a25d9250238ad64ed5da03450c6a3f4f8f4dcdf0b58d1ed69029d76ead48d"
	blindingMaskHex       = "be6e7a4256cac6f4d4ed4639b8c39c4cb8bece40010908e70d17ea9d77b4dc57f1da36f2d6641ccb37cf2b9f3146686462e0fa3161ae74f88c0afd4e307adbd5"
	aliceUnblindedPayload = "010002b85034fb08a8bfefd22848238257b252721454bbbfba2c3667f168837ea2cdad671af9f65904632e2dcc0c6ad314e11d53fc82fa4c4ea27a4a14eccecc478fee00000000000000000000000000"
	aliceBlindedPayload   = "010002063e4eb95e62791b06c50e1a3a942e1ecaaa9afbbeb324d16ae6821e091611fa96c0cf048f607fe51a0327f5e2528979311c78cb2de0d682c61e1180fc3d543b00000000000000000000000000"
)

// First 10 P2PKH addresses Alice → Bob.
var aliceToBobAddresses = [10]string{
	"141fi7TY3h936vRUKh1qfUZr8rSBuYbVBK",
	"12u3Uued2fuko2nY4SoSFGCoGLCBUGPkk6",
	"1FsBVhT5dQutGwaPePTYMe5qvYqqjxyftc",
	"1CZAmrbKL6fJ7wUxb99aETwXhcGeG3CpeA",
	"1KQvRShk6NqPfpr4Ehd53XUhpemBXtJPTL",
	"1KsLV2F47JAe6f8RtwzfqhjVa8mZEnTM7t",
	"1DdK9TknVwvBrJe7urqFmaxEtGF2TMWxzD",
	"16DpovNuhQJH7JUSZQFLBQgQYS4QB9Wy8e",
	"17qK2RPGZMDcci2BLQ6Ry2PDGJErrNojT5",
	"1GxfdfP286uE24qLZ9YRP3EWk2urqXgC4s",
}
