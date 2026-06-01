## Package Documentation

Every Go package contained by a directory should have a `doc.go` file with a package-level comment:

```go
// Package foobar <brief description of this package>
package foobar
```

When adding a new package, create a `doc.go` file following this pattern. `cmd/` packages (which are `package main`) are exempt.
