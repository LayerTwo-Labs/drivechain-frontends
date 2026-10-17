package database

import (
	"context"
	"database/sql"
	_ "embed"
	"errors"
	"fmt"
	"os"
	"runtime/debug"
	"strings"
	"time"

	"github.com/rs/zerolog"
)

type TestingLog interface {
	zerolog.TestingLog
	FailNow()
	Name() string
	Cleanup(func())
}

// Test creates a new migrated database for the given test, named after the
// package under test.
func Test(t TestingLog) *sql.DB {
	pack := getPackageUnderTest()

	database, tmpfile, err := actualGetDatabase(pack)
	if err != nil {
		t.Logf("unable to get database: %s", err)
		t.FailNow()
	}
	t.Logf("created database %s", tmpfile)

	// Register cleanup
	t.Cleanup(func() {
		if err := database.Close(); err != nil {
			t.Logf("close database %s: %s", tmpfile, err)
			t.FailNow()
		}
		type canFail interface {
			Failed() bool
		}
		if _, ok := t.(canFail); ok && t.(canFail).Failed() {
			t.Logf("test has failed, NOT removing database %s", tmpfile)
			return
		}
		if err := os.Remove(tmpfile); err != nil {
			t.Logf("remove database %s: %s", tmpfile, err)
			t.FailNow()
		}
	})

	return database
}

func actualGetDatabase(
	name string,
) (*sql.DB, string, error) {
	ctx := context.Background()
	log := zerolog.Ctx(ctx)

	start := time.Now()
	log.Debug().Msgf("creating database %s", name)

	// Create a unique database file for this package
	tmpfile, err := os.CreateTemp("", fmt.Sprintf("%s-*.db", name))
	if err != nil {
		return nil, "", fmt.Errorf("create temp file: %w", err)
	}
	if err := tmpfile.Close(); err != nil {
		return nil, "", errors.Join(fmt.Errorf("close temp file: %w", err), os.Remove(tmpfile.Name()))
	}

	migrateCtx := zerolog.Ctx(ctx).Level(zerolog.WarnLevel).WithContext(ctx)
	db, err := open(migrateCtx, tmpfile.Name())
	if err != nil {
		return nil, "", errors.Join(err, os.Remove(tmpfile.Name()))
	}

	log.Info().Msgf("finished creating test database %q in %s", name, time.Since(start))
	return db, tmpfile.Name(), nil
}

// getPackageUnderTest names the package of the first caller outside this package, from the call stack.
func getPackageUnderTest() string {
	firstNonDbFile := firstNonDbCaller(debug.Stack())
	localPartSegments := strings.Split(firstNonDbFile, string(os.PathSeparator))
	fullPackagePath := strings.Join(
		// take all segments except the last one, as that's the file name
		localPartSegments[:len(localPartSegments)-1],
		"_")

	// We're testing the DB package itself!
	if strings.HasPrefix(fullPackagePath, "go_pkg_mod") ||

		// happens on CI?
		strings.HasPrefix(fullPackagePath, "opt_hostedtoolcache_go") {
		return "db"
	}

	return fullPackagePath
}

func firstNonDbCaller(stack []byte) string {
	var goFileLines []string

	// first lines are debug.Stack() frame
	for _, line := range strings.Split(string(stack), "\n")[3:] {
		// filter out all lines which aren't go source files
		if strings.Contains(line, ".go") {
			goFileLines = append(goFileLines, strings.TrimSpace(line))
		}
	}

	var (
		lastDb, firstNonDb string
	)
	for idx, line := range goFileLines {
		if strings.Contains(line, "database/db") {
			continue
		}

		lastDb = goFileLines[idx-1]
		firstNonDb = line
		break
	}
	lastDb = strings.TrimSpace(lastDb)
	firstNonDb = strings.TrimSpace(firstNonDb)

	return strings.TrimPrefix(firstNonDb, commonPrefix(firstNonDb, lastDb))
}

func commonPrefix(first, second string) string {
	var out string
	for idx := range first {
		if first[idx] != second[idx] {
			break
		}
		out += string(first[idx])
	}
	return out
}
