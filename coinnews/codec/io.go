package coinnews

// writer is the subset of bytes.Buffer we need for encoding. Declared
// here so encode helpers can take any byte sink without depending on
// `bytes` and so tests can swap in a fake.
type writer interface {
	WriteByte(byte) error
	Write([]byte) (int, error)
}
