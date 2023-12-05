set -e 

# Dirty hack: we're running the big build script
# from within bash in WSL, and we need to go back
# to Windows land when doing the Flutter build.

# Screwing around with app names and such doesn't play
# nice with the Flutter caches. Do a proper clean
# before building.
clean_cmd="flutter clean"
build_cmd="dart run msix:create"

powershell.exe -Command "& {$clean_cmd; $build_cmd; exit}"