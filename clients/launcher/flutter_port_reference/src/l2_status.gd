extends Control

# Delay between run status updates (in seconds)
# In Flutter: Use Timer.periodic or Stream.periodic
const RUN_STATUS_UPDATE_DELAY : int = 10

# Layer 2 chain information
# In Flutter: Store in a configuration class
var l2_title : String = "LAYERTWOTITLE"
var l2_description : String = "LAYERTWODESC"

# Layer 1 status flags
# In Flutter: Use a state management solution (e.g., Provider, Bloc)
var l1_software_ready : bool = false
var l1_software_running: bool = false

# Status signals
# In Flutter: Use callbacks or Streams for status updates
signal l2_started(pid : int)
signal l2_start_l1_message_requested()
signal l2_setup_l1_message_requested()
signal l2_requested_removal()

# Process ID for L2 chain
# In Flutter: Use platform-specific process management
var l2_pid : int = -1

# Timer for status updates
# In Flutter: Use Timer.periodic or Stream.periodic
var timer_run_status_update = null

# Set Layer 2 chain information
# In Flutter: Use a configuration class or state management
func set_l2_info(title : String, description : String) -> void:
    l2_title = title
    l2_description = description
    
    # Update UI elements
    # In Flutter: Use setState or state management to update UI
    $PanelContainer/VBoxContainer/LabelTitle.text = l2_title
    $PanelContainer/VBoxContainer/LabelDescription.text = l2_description
    
    $PanelContainer/VBoxContainer/ButtonStartL2.text = str("Start ", l2_title)
    $PanelContainer/VBoxContainer/ButtonSetupL2.text = str("Setup ", l2_title)
    $PanelContainer/VBoxContainer/HBoxContainerDownloadStatus/LabelDownloadTitle.text = str(l2_title, ":")

# Update setup status and UI
# In Flutter: Use setState or state management to update UI
func update_setup_status() -> void:
    var l2_ready : bool = $ResourceDownloader.have_thunder()
    var l2_downloading : bool = $PanelContainer/VBoxContainer/DownloadProgress.visible
    
    if l2_ready:
        $PanelContainer/VBoxContainer/HBoxContainerL2Options/ButtonRemove.disabled = false
    
    # Update UI based on status
    if l2_ready:
        $PanelContainer/VBoxContainer/DownloadProgress.visible = false
        $PanelContainer/VBoxContainer/ButtonSetupL2.visible = false
        $PanelContainer/VBoxContainer/ButtonStartL2.visible = true
    else:
        if !l2_downloading:
            $PanelContainer/VBoxContainer/ButtonSetupL2.visible = true
        $PanelContainer/VBoxContainer/ButtonStartL2.visible = false

    # Update status text
    var l2_status_text : String = ""
    if l2_ready:
        l2_status_text = "L2 Software: Ready!"
    elif l2_downloading:
        l2_status_text = "L2 Software: Downloading..."
    else:
        l2_status_text = "L2 Software: Not Found"
        
    $PanelContainer/VBoxContainer/LabelSetupStatus.text = l2_status_text 

# Handle setup button press
# In Flutter: Use a callback or state management action
func _on_button_setup_pressed() -> void:
    $PanelContainer/VBoxContainer/ButtonSetupL2.visible = false
    $PanelContainer/VBoxContainer/HBoxContainerDownloadStatus.visible = true
    $PanelContainer/VBoxContainer/LabelSetupStatus.visible = true
    
    # Start download process
    # TODO: Support other L2 chains besides Thunder
    $ResourceDownloader.download_thunder()

# Start Layer 2 chain
# In Flutter: Use platform-specific process management
func start_l2() -> void:
    # Check L1 prerequisites
    if !l1_software_ready:
        l2_setup_l1_message_requested.emit()
        return

    if !l1_software_running:
        l2_start_l1_message_requested.emit()
        return
        
    var downloads_dir : String = str(OS.get_user_data_dir(), "/downloads/l2")

    # Get platform-specific binary path
    # In Flutter: Use path_provider package for paths
    var l2_bin_path : String = ""
    match OS.get_name():
        "Linux":
            l2_bin_path = str(downloads_dir, "/thunder-latest-x86_64-unknown-linux-gnu")
        "Windows":
            l2_bin_path = str(downloads_dir, "/thunder-latest-x86_64-pc-windows-gnu.exe")
        "macOS":
            l2_bin_path = str(downloads_dir, "/thunder-latest-x86_64-apple-darwin")

    # Start L2 process
    # In Flutter: Use process_run package for process management
    var ret : int = OS.create_process(l2_bin_path, [])
    if ret == -1:
        printerr("Failed to start ", l2_title)
        return
    
    # Update UI
    $PanelContainer/VBoxContainer/ButtonStartL2.visible = false
    print("started ", l2_title, " with pid: ", ret)
    
    # Signal PID to main window
    l2_started.emit(ret)
    
    l2_pid = ret
    
    $PanelContainer/VBoxContainer/LabelRunStatus.visible = true
    $PanelContainer/VBoxContainer/LabelRunStatus.text = str("Starting ", l2_title, "...")
    
    # Setup status update timer
    if timer_run_status_update != null:
        timer_run_status_update.queue_free()
    
    timer_run_status_update = Timer.new()
    add_child(timer_run_status_update)
    timer_run_status_update.connect("timeout", check_running_status)
    
    timer_run_status_update.start(RUN_STATUS_UPDATE_DELAY)

    # Show L2 options
    $PanelContainer/VBoxContainer/HBoxContainerL2Options.visible = true
    $PanelContainer/VBoxContainer/HBoxContainerL2Options/ButtonRestart.disabled = false

# Handle start button press
# In Flutter: Use a callback or state management action
func _on_button_start_pressed() -> void:
    start_l2()

# Check L2 running status
# In Flutter: Use periodic timer or stream
func check_running_status() -> void:
    $RPCClient.cli_thunder_getblockcount()

# Handle Thunder download progress
# In Flutter: Use Stream<double> for progress updates
func _on_resource_downloader_resource_thunder_download_progress(percent: int) -> void:
    $PanelContainer/VBoxContainer/HBoxContainerDownloadStatus/ProgressL2.value = percent

# Handle Thunder ready status
# In Flutter: Use callback or state management action
func _on_resource_downloader_resource_thunder_ready() -> void:
    update_setup_status()
    $PanelContainer/VBoxContainer/HBoxContainerDownloadStatus.visible = false
    $PanelContainer/VBoxContainer/HBoxContainerL2Options/ButtonRemove.disabled = false

# Set L1 ready status
# In Flutter: Use state management
func set_l1_ready() -> void:
    l1_software_ready = true

# Set L1 running status
# In Flutter: Use state management
func set_l1_running() -> void:
    l1_software_running = true

# Handle reset
# In Flutter: Use state management action
func handle_reset() -> void:
    print("L2 handle reset")
    l1_software_running = false
    l1_software_ready = false
    $PanelContainer/VBoxContainer/LabelRunStatus.visible = false
    update_setup_status()
    
    $PanelContainer/VBoxContainer/HBoxContainerL2Options/ButtonRestart.disabled = true
    $PanelContainer/VBoxContainer/HBoxContainerL2Options/ButtonRemove.disabled = true

# Handle new block count
# In Flutter: Use Stream or callback
func _on_rpc_client_thunder_new_block_count(height: int) -> void:
    $PanelContainer/VBoxContainer/LabelRunStatus.text = str("Blocks: ", height)

# Handle Thunder CLI failure
# In Flutter: Use error callback or error stream
func _on_rpc_client_thunder_cli_failed() -> void:
    $PanelContainer/VBoxContainer/LabelRunStatus.text = str("Error: Thunder not responding!")

# Handle restart button press
# In Flutter: Use callback or state management action
func _on_button_restart_pressed() -> void:
    restart_l2()

# Handle remove button press
# In Flutter: Use callback or state management action
func _on_button_remove_pressed() -> void:
    $PanelContainer/ConfirmationDialogRemoveL2.show()

# Handle remove confirmation
# In Flutter: Use callback or state management action
func _on_confirmation_dialog_remove_l2_confirmed() -> void:
    l2_requested_removal.emit()

# Restart L2 process
# In Flutter: Use platform-specific process management
func restart_l2() -> void:
    OS.kill(l2_pid)
    await get_tree().create_timer(1.0).timeout
    start_l2()
