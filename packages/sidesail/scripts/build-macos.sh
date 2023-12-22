set -e

app_name="$1"
# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 app_name"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')


echo Building $app_name

flutter build macos --dart-define-from-file=build-vars.env

zip_name=$lower_app_name-osx64.zip 
echo Zipping into $zip_name

cd ./build/macos/Build/Products/Release 
ditto -c -k --sequesterRsrc --keepParent $app_name.app testsail-osx64.zip 
zip -9rq $zip_name ./$app_name.app 
