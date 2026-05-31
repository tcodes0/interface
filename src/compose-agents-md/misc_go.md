go: run go mod tidy after making changes to go.mod and dependencies.
go: avoid multi line if conditions with samber/lo functions.
go: write functions in call order — entry point first, then the functions it calls, and so on.
go: receivers and loop vars are exceptions to single-letter var names.
go: Wrap errors with context: "doing something: error 404".
go: Use `errors.Is` and `errors.As` for checking.
go: mock\_\*.go files can be ignored entirely while working, if there are test errors, regenerate mocks.
**Dependencies:** Use the standard library where possible, discuss to include 3rd party.
