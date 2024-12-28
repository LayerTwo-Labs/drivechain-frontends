extends Control

# Debug flag for logging request details
var DEBUG_REQUESTS : bool = false

# Download URLs for each component by platform
# GRPCURL - Command line tool for interacting with gRPC servers
const URL_GRPCURL_LIN : String = "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_x86_64.tar.gz"
const URL_GRPCURL_WIN : String = "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_windows_x86_64.zip"
const URL_GRPCURL_OSX : String = "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_osx_x86_64.tar.gz"

# BIP300301 Enforcer - Manages drivechain validation rules
const URL_300301_ENFORCER_LIN  : String = "https://releases.drivechain.info/bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip"
const URL_300301_ENFORCER_WIN : String = "https://releases.drivechain.info/bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip"
const URL_300301_ENFORCER_OSX : String = "https://releases.drivechain.info/bip300301-enforcer-latest-x86_64-apple-darwin.zip"

# Bitcoin Core (Patched) - Modified Bitcoin implementation for drivechain support
const URL_BITCOIN_PATCHED_LIN : String = "https://releases.drivechain.info/L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu.zip"
const URL_BITCOIN_PATCHED_WIN : String = "https://releases.drivechain.info/L1-bitcoin-patched-latest-x86_64-w64-msvc.zip"
const URL_BITCOIN_PATCHED_OSX : String = "https://releases.drivechain.info/L1-bitcoin-patched-latest-x86_64-apple-darwin.zip"

# BitWindow - GUI for managing drivechain operations
const URL_BITWINDOW_LIN : String = "https://releases.drivechain.info/BitWindow-latest-x86_64-unknown-linux-gnu.zip"
const URL_BITWINDOW_WIN : String = "https://releases.drivechain.info/BitWindow-latest-x86_64-pc-windows-msvc.zip"
const URL_BITWINDOW_OSX : String = "https://releases.drivechain.info/BitWindow-latest-x86_64-apple-darwin.zip"

# Thunder - Layer 2 sidechain implementation
const URL_THUNDER_LIN : String = "https://releases.drivechain.info/L2-S9-Thunder-latest-x86_64-unknown-linux-gnu.zip"
const URL_THUNDER_WIN : String = "https://releases.drivechain.info/L2-S9-Thunder-latest-x86_64-pc-windows-gnu.zip"
const URL_THUNDER_OSX : String = "https://releases.drivechain.info/L2-S9-Thunder-latest-x86_64-apple-darwin.zip"

# Download paths - Note: GRPCURL uses different extensions per platform
const DOWNLOAD_PATH_GRPCURL_LIN_OSX = "user://downloads/l1/grpcurl.tar.gz"
const DOWNLOAD_PATH_GRPCURL_WIN = "user://downloads/l1/grpcurl.zip"

# How often to update download progress (in seconds)
const DOWNLOAD_PROGRESS_UPDATE_DELAY : float = 0.1

# HTTP Request nodes for downloading each component
# In Flutter: Replace with HTTP client or download manager
@onready var http_download_grpcurl: HTTPRequest = $HTTPDownloadGRPCURL
@onready var http_download_enforcer: HTTPRequest = $HTTPDownloadEnforcer
@onready var http_download_bitcoin: HTTPRequest = $HTTPDownloadBitcoin
@onready var http_download_thunder: HTTPRequest = $HTTPDownloadThunder
@onready var http_download_bit_window: HTTPRequest = $HTTPDownloadBitWindow

# Timers for tracking download progress
# In Flutter: Use Stream/StreamController for progress updates
var timer_l1_download_progress_update = null
var timer_l2_download_progress_update = null

# Signals for component readiness
# In Flutter: Use callbacks or streams to notify state changes
signal resource_grpcurl_ready
signal resource_bitcoin_ready
signal resource_bitwindow_ready
signal resource_enforcer_ready
signal resource_thunder_ready

# Signals for download progress
# In Flutter: Use Stream<double> for progress updates
signal resource_grpcurl_download_progress(percent : int)
signal resource_bitcoin_download_progress(percent : int)
signal resource_bitwindow_download_progress(percent : int)
signal resource_enforcer_download_progress(percent : int)
signal resource_thunder_download_progress(percent : int)

# Track L1 software download progress
# In Flutter: Use a StreamController to emit progress updates
func track_l1_download_progress() -> void:
    # Don't create a new timer if we already started tracking progress
    if timer_l1_download_progress_update != null:
        return
        
    # Create timer to check on download progress of L1 software
    # In Flutter: Use Stream.periodic or Timer.periodic
    timer_l1_download_progress_update = Timer.new()
    add_child(timer_l1_download_progress_update)
    timer_l1_download_progress_update.connect("timeout", check_l1_download_progress)
    
    timer_l1_download_progress_update.start(DOWNLOAD_PROGRESS_UPDATE_DELAY)

# Check and emit L1 download progress
# In Flutter: Implement as a Stream that emits progress updates
func check_l1_download_progress() -> void:
    # Display the current download progress for all L1 software
    
    var bytesBody : int = 0
    var bytesHave : int = 0
    var percent : int = 0
    
    var downloads_complete : bool = true
    
    # Calculate and emit progress for each component
    # In Flutter: Use a single Stream that emits a map of progress values
    
    # GRPCURL download progress
    bytesBody = $HTTPDownloadGRPCURL.get_body_size()
    bytesHave = $HTTPDownloadGRPCURL.get_downloaded_bytes()
    percent = int(bytesHave * 100 / bytesBody)
    resource_grpcurl_download_progress.emit(percent)
    
    if percent != 100:
        downloads_complete = false
    
    # Enforcer download progress
    bytesBody = $HTTPDownloadEnforcer.get_body_size()
    bytesHave = $HTTPDownloadEnforcer.get_downloaded_bytes()
    percent = int(bytesHave * 100 / bytesBody)
    resource_enforcer_download_progress.emit(percent)

    if percent != 100:
        downloads_complete = false

    # Bitcoin download progress
    bytesBody = $HTTPDownloadBitcoin.get_body_size()
    bytesHave = $HTTPDownloadBitcoin.get_downloaded_bytes()
    percent = int(bytesHave * 100 / bytesBody)
    resource_bitcoin_download_progress.emit(percent)
    
    if percent != 100:
        downloads_complete = false
    
    # BitWindow download progress
    bytesBody = $HTTPDownloadBitWindow.get_body_size()
    bytesHave = $HTTPDownloadBitWindow.get_downloaded_bytes()
    percent = int(bytesHave * 100 / bytesBody)
    resource_bitwindow_download_progress.emit(percent)
    
    if percent != 100:
        downloads_complete = false
    
    # If everything is done, stop the timer
    if downloads_complete:
        timer_l1_download_progress_update.queue_free()

# Track L2 software download progress
# In Flutter: Similar to L1 progress tracking but for L2 components
func track_l2_download_progress() -> void:
    if timer_l2_download_progress_update != null:
        return
        
    timer_l2_download_progress_update = Timer.new()
    add_child(timer_l2_download_progress_update)
    timer_l2_download_progress_update.connect("timeout", check_l2_download_progress)
    
    timer_l2_download_progress_update.start(DOWNLOAD_PROGRESS_UPDATE_DELAY)

# Check and emit L2 download progress
# In Flutter: Use a Stream for L2 progress updates
func check_l2_download_progress() -> void:
    var bytesBody : int = 0
    var bytesHave : int = 0
    var percent : int = 0
    
    var downloads_complete : bool = true

    # Thunder download progress
    bytesBody = $HTTPDownloadThunder.get_body_size()
    bytesHave = $HTTPDownloadThunder.get_downloaded_bytes()
    percent = int(bytesHave * 100 / bytesBody)
    resource_thunder_download_progress.emit(percent)
    
    if percent != 100:
        downloads_complete = false
    
    if downloads_complete:
        timer_l2_download_progress_update.queue_free()

# Check if GRPCURL is installed
# In Flutter: Use platform-specific file access APIs
func have_grpcurl() -> bool:
    match OS.get_name():
        "Linux":
            if !FileAccess.file_exists("user://downloads/l1/grpcurl"):
                return false
        "Windows":
            if !FileAccess.file_exists("user://downloads/l1/grpcurl.exe"):
                return false
        "macOS":
            if !FileAccess.file_exists("user://downloads/l1/grpcurl"):
                return false
                
    resource_grpcurl_ready.emit()
    return true

# Check if Enforcer is installed
# In Flutter: Use platform-specific file access APIs
func have_enforcer() -> bool:
    match OS.get_name():
        "Linux":
            if !FileAccess.file_exists("user://downloads/l1/bip300301-enforcer-latest-x86_64-unknown-linux-gnu/bip300301_enforcer-0.1.0-x86_64-unknown-linux-gnu"):
                return false
        "Windows":
            if !FileAccess.file_exists("user://downloads/l1/bip300301-enforcer-latest-x86_64-pc-windows-gnu.exe/bip300301_enforcer-0.1.0-x86_64-pc-windows-gnu.exe"):
                return false
        "macOS":
            if !FileAccess.file_exists("user://downloads/l1/bip300301-enforcer-latest-x86_64-apple-darwin/bip300301_enforcer-0.1.0-x86_64-apple-darwin"):
                return false
    
    resource_enforcer_ready.emit()
    return true

# Check if Bitcoin Core is installed
# In Flutter: Use platform-specific file access APIs
func have_bitcoin() -> bool:
    match OS.get_name():
        "Linux":
            if !FileAccess.file_exists("user://downloads/l1/L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu/bitcoind"):
                return false
        "Windows":
            if !FileAccess.file_exists("user://downloads/l1/L1-bitcoin-patched-latest-x86_64-w64-msvc/Release/bitcoind.exe"):
                return false
        "macOS":
            if !FileAccess.file_exists("user://downloads/l1/L1-bitcoin-patched-latest-x86_64-apple-darwin/bitcoind"):
                return false

    resource_bitcoin_ready.emit()
    return true

# Check if BitWindow is installed
# In Flutter: Use platform-specific file access APIs
func have_bitwindow() -> bool:
    match OS.get_name():
        "Linux":
            if !FileAccess.file_exists("user://downloads/l1/bitwindow/bitwindow"):
                return false
        "Windows":
            if !FileAccess.file_exists("user://downloads/l1/bitwindow.exe"):
                return false
        "macOS":
            if !FileAccess.file_exists("user://downloads/l1/bitwindow/bitwindow.app/Contents/MacOS/bitwindow"):
                return false

    resource_bitwindow_ready.emit()
    return true

# Check if Thunder is installed
# In Flutter: Use platform-specific file access APIs
func have_thunder() -> bool:
    match OS.get_name():
        "Linux":
            if !FileAccess.file_exists("user://downloads/l2/thunder-latest-x86_64-unknown-linux-gnu"):
                return false
        "Windows":
            if !FileAccess.file_exists("user://downloads/l2/thunder-latest-x86_64-pc-windows-gnu.exe"):
                return false
        "macOS":
            if !FileAccess.file_exists("user://downloads/l2/thunder-latest-x86_64-apple-darwin"):
                return false

    return true

# Download GRPCURL if not present
# In Flutter: Use http package or platform-specific download manager
func download_grpcurl() -> void:
    if have_grpcurl():
        return
        
    track_l1_download_progress()
        
    DirAccess.make_dir_absolute("user://downloads/")
    DirAccess.make_dir_absolute("user://downloads/l1")
        
    match OS.get_name():
        "Linux":
            $HTTPDownloadGRPCURL.download_file = DOWNLOAD_PATH_GRPCURL_LIN_OSX
            $HTTPDownloadGRPCURL.request(URL_GRPCURL_LIN)
        "Windows":
            $HTTPDownloadGRPCURL.download_file = DOWNLOAD_PATH_GRPCURL_WIN
            $HTTPDownloadGRPCURL.request(URL_GRPCURL_WIN)
        "macOS":
            $HTTPDownloadGRPCURL.download_file = DOWNLOAD_PATH_GRPCURL_LIN_OSX
            $HTTPDownloadGRPCURL.request(URL_GRPCURL_OSX)

# Download Enforcer if not present
# In Flutter: Use http package or platform-specific download manager
func download_enforcer() -> void:
    if have_enforcer():
        return
    
    track_l1_download_progress()
    
    DirAccess.make_dir_absolute("user://downloads/")
    DirAccess.make_dir_absolute("user://downloads/l1")
    
    match OS.get_name():
        "Linux":
            $HTTPDownloadEnforcer.request(URL_300301_ENFORCER_LIN)
        "Windows":
            $HTTPDownloadEnforcer.request(URL_300301_ENFORCER_WIN)
        "macOS":
            $HTTPDownloadEnforcer.request(URL_300301_ENFORCER_OSX)

# Download Bitcoin Core if not present
# In Flutter: Use http package or platform-specific download manager
func download_bitcoin() -> void:
    if have_bitcoin():
        return
        
    track_l1_download_progress()
    
    DirAccess.make_dir_absolute("user://downloads/")
    DirAccess.make_dir_absolute("user://downloads/l1")

    match OS.get_name():
        "Linux":
            $HTTPDownloadBitcoin.request(URL_BITCOIN_PATCHED_LIN)
        "Windows":
            $HTTPDownloadBitcoin.request(URL_BITCOIN_PATCHED_WIN)
        "macOS":
            $HTTPDownloadBitcoin.request(URL_BITCOIN_PATCHED_OSX)

# Download BitWindow if not present
# In Flutter: Use http package or platform-specific download manager
func download_bitwindow() -> void:
    if have_bitwindow():
        return

    track_l1_download_progress()
    
    DirAccess.make_dir_absolute("user://downloads/")
    DirAccess.make_dir_absolute("user://downloads/l1")

    match OS.get_name():
        "Linux":
            $HTTPDownloadBitWindow.request(URL_BITWINDOW_LIN)
        "Windows":
            $HTTPDownloadBitWindow.request(URL_BITWINDOW_WIN)
        "macOS":
            $HTTPDownloadBitWindow.request(URL_BITWINDOW_OSX)

# Download Thunder if not present
# In Flutter: Use http package or platform-specific download manager
func download_thunder() -> void:
    if have_thunder():
        return

    track_l2_download_progress()

    DirAccess.make_dir_absolute("user://downloads/")
    DirAccess.make_dir_absolute("user://downloads/l2")

    match OS.get_name():
        "Linux":
            $HTTPDownloadThunder.request(URL_THUNDER_LIN)
        "Windows":
            $HTTPDownloadThunder.request(URL_THUNDER_WIN)
        "macOS":
            $HTTPDownloadThunder.request(URL_THUNDER_OSX)

# Extract downloaded GRPCURL archive
# In Flutter: Use platform-specific archive extraction
func extract_grpcurl() -> void:
    var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")
    
    var ret : int = -1 
    match OS.get_name():
        "Linux":
            ret = OS.execute("tar", ["-xzf", str(downloads_dir, "/grpcurl.tar.gz"), "-C", downloads_dir])
        "Windows":
            ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/grpcurl.zip")])
        "macOS":
            ret = OS.execute("tar", ["-xzf", str(downloads_dir, "/grpcurl.tar.gz"), "-C", downloads_dir])

    if ret != OK:
        printerr("Failed to extract grpcurl")
        return
        
    resource_grpcurl_ready.emit()

# Extract downloaded Enforcer archive
# In Flutter: Use platform-specific archive extraction
func extract_enforcer() -> void:
    var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")

    var ret : int = -1
    match OS.get_name():
        "Linux":
            ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/300301enforcer.zip")])
        "Windows":
            ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/300301enforcer.zip")])
        "macOS":
            ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/300301enforcer.zip")])

    if ret != OK:
        printerr("Failed to extract enforcer")
        return

    # Make executable for linux
    if OS.get_name() == "Linux":
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/bip300301-enforcer-latest-x86_64-unknown-linux-gnu/bip300301_enforcer-0.1.0-x86_64-unknown-linux-gnu")])
        if ret != OK:
            printerr("Failed to mark enforcer executable")
            return

    resource_enforcer_ready.emit()
    
    if OS.get_name() == "macOS":
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/bip300301-enforcer-latest-x86_64-apple-darwin/bip300301_enforcer-0.1.0-x86_64-apple-darwin")])
        if ret != OK:
            printerr("Failed to mark enforcer executable")
            return

# Extract downloaded Bitcoin Core archive
# In Flutter: Use platform-specific archive extraction
func extract_bitcoin() -> void:
    var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")

    var ret : int = -1
    match OS.get_name():
        "Linux":
            ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/bitcoinpatched.zip")])
        "Windows":
            ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/bitcoinpatched.zip")])
        "macOS":
            ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/bitcoinpatched.zip")])

    if ret != OK:
        printerr("Failed to extract bitcoin")
        return
        
    if OS.get_name() == "Linux":
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu/bitcoind")])
        if ret != OK:
            printerr("Failed to mark bitcoin executable")
            return
            
    if OS.get_name() == "macOS":
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/L1-bitcoin-patched-latest-x86_64-apple-darwin/bitcoind")])
        if ret != OK:
            printerr("Failed to mark bitcoin executable")
            return
            
    resource_bitcoin_ready.emit()

# Extract downloaded BitWindow archive
# In Flutter: Use platform-specific archive extraction
func extract_bitwindow() -> void:
    var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")

    var ret : int = -1
    match OS.get_name():
        "Linux":
            ret = OS.execute("unzip", ["-o", "-d", str(downloads_dir, "/bitwindow"), str(downloads_dir, "/bitwindow.zip")])
        "Windows":
            ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/bitwindow.zip")])
        "macOS":
            DirAccess.make_dir_absolute(str(downloads_dir, "/bitwindow"))
            ret = OS.execute("unzip", ["-o", "-d", str(downloads_dir, "/bitwindow"), str(downloads_dir, "/bitwindow.zip")])
            if ret == OK:
                ret = OS.execute("chmod", ["+x", str(downloads_dir, "/bitwindow/bitwindow.app/Contents/MacOS/bitwindow")])

    if ret != OK:
        printerr("Failed to extract bitwindow with return code: ", ret)
        return
        
    resource_bitwindow_ready.emit()

# Extract downloaded Thunder archive
# In Flutter: Use platform-specific archive extraction
func extract_thunder() -> void:
    var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l2")
    
    var ret : int = -1
    match OS.get_name():
        "Linux":
            ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/thunder.zip")])
        "Windows":
            ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/thunder.zip")])
        "macOS":
            ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/thunder.zip")])

    if ret != OK:
        printerr("Failed to extract thunder")
        return

    if OS.get_name() == "Linux":
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-cli-latest-x86_64-unknown-linux-gnu")])
        if ret != OK:
            printerr("Failed to mark thunder-cli executable")
            return
            
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-latest-x86_64-unknown-linux-gnu")])
        if ret != OK:
            printerr("Failed to mark thunder executable")
            return
    elif OS.get_name() == "macOS":
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-cli-latest-x86_64-apple-darwin")])
        if ret != OK:
            printerr("Failed to mark thunder-cli executable")
            return
        ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-latest-x86_64-apple-darwin")])
        if ret != OK:
            printerr("Failed to mark thunder executable")
            return
    resource_thunder_ready.emit()

# Handle download completion callbacks
# In Flutter: Use http package's download completion callbacks
func _on_http_download_grpcurl_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
    if result != OK:
        printerr("Failed to download grpcurl")
        return 
    
    if DEBUG_REQUESTS:
        print("res ", result)
        print("code ", response_code)
        print("Downloaded grpcurl tarball")
    
    extract_grpcurl()

func _on_http_download_enforcer_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
    if result != OK:
        printerr("Failed to download enforcer")
        return 
    
    if DEBUG_REQUESTS:
        print("res ", result)
        print("code ", response_code)
        print("Downloaded enforcer zip")
    
    extract_enforcer()

func _on_http_download_bitcoin_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
    if result != OK:
        printerr("Failed to download bitcoin")
        return 
    
    if DEBUG_REQUESTS:
        print("res ", result)
        print("code ", response_code)
        print("Downloaded bitcoin zip")
    
    # TODO extract in thread so window doesn't freeze
    extract_bitcoin()

func _on_http_download_thunder_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
    if result != OK:
        printerr("Failed to download thunder")
        return 
    
    if DEBUG_REQUESTS:
        print("res ", result)
        print("code ", response_code)
        print("Downloaded thunder zip")
    
    extract_thunder()

func _on_http_download_bit_window_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
    if result != OK:
        printerr("Failed to download bitwindow")
        return 
    
    if DEBUG_REQUESTS:
        print("res ", result)
        print("code ", response_code)
        print("Downloaded bitwindow zip")
    
    # TODO extract in thread so window doesn't freeze
    extract_bitwindow()
