package database

import (
	"context"
	"database/sql"
	_ "embed"
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

// Test creates a database for the given test. It does this
// by extracting the package under test, and creating and caching
// a database. If two tests call the Database method, only a single
// database is created.
func Test(t TestingLog) *sql.DB {
	pack := getPackageUnderTest()

	// Create a new database for each test
	database, tmpfile, err := actualGetDatabase(pack)
	if err != nil {
		t.Logf("unable to get database: %s", err)
		t.FailNow()
	}
	t.Logf("created database %s", tmpfile)

	// Register cleanup
	t.Cleanup(func() {
		database.Close()
		type canFail interface {
			Failed() bool
		}
		if _, ok := t.(canFail); ok && t.(canFail).Failed() {
			t.Logf("test has failed, NOT removing database %s", tmpfile)
		} else {
			os.Remove(tmpfile)
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
		return nil, "", fmt.Errorf("could not create temp file: %v", err)
	}

	// Open the database with SQLite3 configuration
	db, err := sql.Open("sqlite3", tmpfile.Name())
	if err != nil {
		os.Remove(tmpfile.Name()) // Clean up if we fail to open
		return nil, "", fmt.Errorf("could not open database: %v", err)
	}

	// Run migrations
	migrateCtx := zerolog.Ctx(ctx).Level(zerolog.WarnLevel).WithContext(ctx)
	if err := runMigrations(migrateCtx, db); err != nil {
		db.Close()
		os.Remove(tmpfile.Name()) // Clean up if migrations fail
		return nil, "", fmt.Errorf("could not run migrations: %v", err)
	}

	log.Info().Msgf("finished creating test database %q in %s", name, time.Since(start))
	return db, tmpfile.Name(), nil
}

// Ihe idea is to extract out the go file path of the package under test,
// by looking at the callstack. The stack is going to look something like this:
//
//	  debug.Stack()
//	  getPackageUnderTest() 			- this function
//	  Test() 			   			- the root function in this package
//	 								  that's being called
//	  TestNameOfTest(t *testing.T) 	- the test function that invokes the DB
//										  creation function
//
// If we then get the file path of the TestNameOfTest function, we can extract
// the package name. That file path is going to look something like this:
//
//	/home/torkel/some/folder/bb/this/is/the/interesting/part_test.go
//
// The first part of the path (/home/torkel/some/folder/bb) is going to be the
// same for both the interesting file, and the files in this package. If we
// then remove the common prefix, we're left with the folder path of the
// package we're interested in. Remove the last segment (the file) and replace
// slashes with underscores, and we're finished.
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
