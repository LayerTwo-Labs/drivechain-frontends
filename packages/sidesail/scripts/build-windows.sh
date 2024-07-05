set -e 

app_name="$1"
if [ "$app_name" = "" ]; then
    echo "Usage: $0 app_name"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

# Dirty hack: we're running the big build script
# from within bash in WSL, and we need to go back
# to Windows land when doing the Flutter build.

# Screwing around with app names and such doesn't play
# nice with the Flutter caches. Do a proper clean
# before building.
clean_cmd="flutter clean"
build_cmd="flutter build --verbose windows --dart-define-from-file=build-vars.env"

powershell.exe -Command "& {$clean_cmd; $build_cmd; exit \$LASTEXITCODE}"

zip_name=$lower_app_name-win64.zip
mkdir -p release

powershell.exe -Command "Compress-Archive -Force build\windows\x64\x64\Release\* release/$zip_name"