package fiovb

import "github.com/OpenPixelSystems/go-fiovb/teec"

const (
	readPersistValue   = 0
	writePersistValue  = 1
	deletePersistValue = 2
	maxBuffer          = 4096
)

var (
	// Universally Unique IDentifier (UUID) as defined in RFC4122.
	// These UUID values are used to identify the fiovb Trusted Application.
	destination = teec.UUID{
		TimeLow:          0x22250a54,
		TimeMid:          0x0bf1,
		TimeHiAndVersion: 0x48fe,
		ClockSeqAndNode:  [8]byte{0x80, 0x02, 0x7b, 0x20, 0xf1, 0xc9, 0xc9, 0xb1},
	}
)

type FIOVB struct {
	t *teec.TEEC
}

func New() *FIOVB {
	return &FIOVB{
		t: teec.New(),
	}
}

func (fiovb *FIOVB) Initialize() error {
	if err := fiovb.t.Initialize(); err != nil {
		return err
	}

	if err := fiovb.t.OpenSession(destination); err != nil {
		return err
	}

	return nil
}

func (fiovb *FIOVB) Read(name string) (string, error) {
	req := []byte(name)
	res := make([]byte, maxBuffer-1)

	operation := teec.Operation{
		ParamTypes: [4]teec.ParameterTypes{
			teec.MEMREF_TEMP_INPUT,
			teec.MEMREF_TEMP_INOUT,
			teec.NONE,
			teec.NONE,
		},
		Params: [4]teec.Parameter{
			teec.Parameter{Buffer: req, Size: uint32(len(req) + 1)},
			teec.Parameter{Buffer: res, Size: uint32(len(res))},
		},
	}

	origin := uint32(0)

	if err := fiovb.t.InvokeCommand(readPersistValue, &operation, &origin); err != nil {
		return "", err
	}

	return string(operation.Params[1].Buffer), nil
}

func (fiovb *FIOVB) Finalize() error {
	if err := fiovb.t.CloseSession(); err != nil {
		return err
	}

	if err := fiovb.t.Finalize(); err != nil {
		return err
	}

	return nil
}
