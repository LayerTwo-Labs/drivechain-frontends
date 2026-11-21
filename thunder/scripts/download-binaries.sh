set -e
set -o pipefail

bash ../scripts/build-drivechaind.sh "$(pwd)/assets/bin"
