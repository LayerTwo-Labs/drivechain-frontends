set -e

export GOBIN=${PWD}/.bin/go
export PATH=$GOBIN:$PATH

if ! which gogroup >/dev/null; then
    echo Installing gogroup
    go install github.com/vasi-stripe/gogroup/cmd/gogroup@latest
    echo -e "Install complete! \n"

fi

WRITE_ARG=""
if test -n "$WRITE"; then
    WRITE_ARG="-rewrite"
fi

deleted=$(git ls-files --deleted)
if test -z "$deleted"; then
    deleted="none"
fi

gogroup $WRITE_ARG \
    -order=std -order=other -order=prefix=$(go list -m | head -1) \
    $(git ls-files | \
        grep --invert-match --file <(echo $deleted) |  \
        grep --regexp '.*\.go$' | \
        grep --invert-match '^gen')
