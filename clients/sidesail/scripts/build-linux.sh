set -e

app_name="$1"
if [ "$app_name" = "" ]; then
    echo "Usage: $0 app_name"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

flutter build linux --dart-define-from-file=build-vars.env

old_cwd=$PWD
cd build/linux/x64/release/bundle

zip_name=$lower_app_name-x86_64-linux-gnu.zip 
echo Zipping into $zip_name

zip -q -r $zip_name *

mkdir -p $old_cwd/release
cp $zip_name $old_cwd/release