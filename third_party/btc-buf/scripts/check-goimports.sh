set -e

export GOBIN=${PWD}/.bin/go
export PATH=$GOBIN:$PATH

if ! which goimports >/dev/null; then
    echo Installing goimports
    go install golang.org/x/tools/cmd/goimports@latest
    echo -e "Install complete! \n"
fi

deleted=$(git ls-files --deleted)
if test -z "$deleted"; then
    deleted="none"
fi

WRITE_ARG=""
if test -n "$WRITE"; then
    WRITE_ARG="-w"
fi

goimports -local $(go list -m | head -1) $WRITE_ARG -l $(git ls-files | \
        grep --invert-match --file <(echo $deleted) |  \
        grep --regexp '.*\.go$' | \
        grep --invert-match '^gen')