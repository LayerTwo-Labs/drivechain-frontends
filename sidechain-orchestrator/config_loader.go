package orchestrator

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/fsnotify/fsnotify"
	"github.com/rs/zerolog"
)

const configFileName = "chains_config.json"

//go:embed chains_config.json
var embeddedConfig []byte

// jsonConfig is the top-level JSON structure.
type jsonConfig struct {
	Version  int                       `json:"version"`
	Binaries map[string]jsonBinaryConf `json:"binaries"`
}

type jsonBinaryConf struct {
	Type        string `json:"type"`
	Name        string `json:"name"`
	Version     string `json:"version"`
	Description string `json:"description"`
	RepoURL     string `json:"repo_url"`
	Port        int    `json:"port"`
	ChainLayer  int    `json:"chain_layer"`
	Slot        int    `json:"slot"`
	Color       string `json:"color"`

	Directories struct {
		Binary          map[string]json.RawMessage `json:"binary"`
		FlutterFrontend map[string]string          `json:"flutter_frontend"`
	} `json:"directories"`

	Download    *jsonDownloadConf `json:"download"`
	AltDownload *jsonDownloadConf `json:"alternative_download"`
	Hashes      map[string]any    `json:"hashes"`
}

type jsonDownloadConf struct {
	Binary           string                     `json:"binary"`
	Files            map[string]json.RawMessage `json:"files"`
	ExtractSubfolder map[string]json.RawMessage `json:"extract_subfolder"`
}

// LoadConfigFile loads binary configs from a chains_config.json file.
// Falls back to the embedded default config on any error.
func LoadConfigFile(path string, log zerolog.Logger) []BinaryConfig {
	data, err := os.ReadFile(path)
	if err != nil {
		log.Info().Str("path", path).Msg("config file not found, using embedded default")
		return loadEmbeddedConfig(log)
	}

	configs, err := parseConfigJSON(data)
	if err != nil {
		log.Warn().Err(err).Str("path", path).Msg("failed to parse config file, using embedded default")
		return loadEmbeddedConfig(log)
	}

	log.Info().Int("count", len(configs)).Str("path", path).Msg("loaded binary configs from file")
	return configs
}

// loadEmbeddedConfig parses the embedded chains_config.json.
// Falls back to AllDefaults() if the embedded config fails to parse.
func loadEmbeddedConfig(log zerolog.Logger) []BinaryConfig {
	configs, err := parseConfigJSON(embeddedConfig)
	if err != nil {
		log.Error().Err(err).Msg("failed to parse embedded config, using hardcoded defaults")
		return AllDefaults()
	}
	log.Info().Int("count", len(configs)).Msg("loaded binary configs from embedded default")
	return configs
}

// ConfigFilePath returns the path to chains_config.json in the given directory.
func ConfigFilePath(dir string) string {
	return filepath.Join(dir, configFileName)
}

// WatchConfigFile watches chains_config.json for changes and calls onChange.
func WatchConfigFile(path string, onChange func([]BinaryConfig), log zerolog.Logger) (func(), error) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return nil, fmt.Errorf("create watcher: %w", err)
	}

	// Watch the directory (more reliable cross-platform than watching a single file)
	dir := filepath.Dir(path)
	if err := watcher.Add(dir); err != nil {
		watcher.Close()
		return nil, fmt.Errorf("watch dir %s: %w", dir, err)
	}

	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				if filepath.Base(event.Name) != configFileName {
					continue
				}
				if event.Op&(fsnotify.Write|fsnotify.Create) == 0 {
					continue
				}

				data, err := os.ReadFile(path)
				if err != nil {
					log.Warn().Err(err).Msg("failed to read updated config file")
					continue
				}
				configs, err := parseConfigJSON(data)
				if err != nil {
					log.Warn().Err(err).Msg("failed to parse updated config file")
					continue
				}
				log.Info().Int("count", len(configs)).Msg("reloaded config from file")
				onChange(configs)

			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Warn().Err(err).Msg("config file watcher error")
			}
		}
	}()

	return func() { watcher.Close() }, nil
}

func parseConfigJSON(data []byte) ([]BinaryConfig, error) {
	var raw jsonConfig
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("unmarshal: %w", err)
	}

	// Use AllDefaults() as a base — JSON overrides fields that are present.
	defaults := make(map[string]BinaryConfig)
	for _, d := range AllDefaults() {
		defaults[d.Name] = d
	}

	var configs []BinaryConfig
	for key, jb := range raw.Binaries {
		bc := jsonToBinaryConfig(key, jb)

		// Merge with defaults: keep Go-specific fields (health check, deps, startup patterns)
		// that aren't in the JSON.
		if def, ok := defaults[bc.Name]; ok {
			bc.HealthCheckType = def.HealthCheckType
			bc.HealthCheckRPC = def.HealthCheckRPC
			bc.Dependencies = def.Dependencies
			bc.StartupLogPatterns = def.StartupLogPatterns
			bc.IsBitcoinCore = def.IsBitcoinCore
			if len(bc.FlutterFrontendDir) == 0 {
				bc.FlutterFrontendDir = def.FlutterFrontendDir
			}
			if len(bc.DataDirMainnet) == 0 {
				bc.DataDirMainnet = def.DataDirMainnet
			}
		}

		configs = append(configs, bc)
	}

	return configs, nil
}

// jsonKeyToName maps JSON keys to internal binary names.
var jsonKeyToName = map[string]string{
	"bitcoincore": "bitcoind",
	"bitwindow":   "bitwindowd",
	"enforcer":    "enforcer",
	"grpcurl":     "grpcurl",
	"thunderd":    "thunderd",
	"zsided":      "zsided",
	"thunder":     "thunder",
	"bitnames":    "bitnames",
	"bitassets":   "bitassets",
	"truthcoin":   "truthcoin",
	"photon":      "photon",
	"coinshift":   "coinshift",
	"zside":       "zside",
}

func jsonToBinaryConfig(key string, jb jsonBinaryConf) BinaryConfig {
	name := jsonKeyToName[key]
	if name == "" {
		name = key
	}

	bc := BinaryConfig{
		Name:        name,
		DisplayName: jb.Name,
		Version:     jb.Version,
		Description: jb.Description,
		RepoURL:     jb.RepoURL,
		Port:        jb.Port,
		ChainLayer:  jb.ChainLayer,
		Slot:        jb.Slot,
	}

	// Parse directories
	bc.DataDir = parseOSMapFromNetworkMap(jb.Directories.Binary, "default")
	bc.DataDirMainnet = parseOSMapFromNetworkMap(jb.Directories.Binary, "mainnet")
	bc.FlutterFrontendDir = jb.Directories.FlutterFrontend

	// Parse download config
	if jb.Download != nil {
		bc.BinaryName = jb.Download.Binary
		bc.DownloadURLs = parseBaseURLs(jb.Download.Files)
		bc.Files = parseOSFiles(jb.Download.Files, "default")
		bc.ForknetFiles = parseOSFiles(jb.Download.Files, "forknet")
		bc.ExtractSubfolder = parseOSMapFromExtract(jb.Download.ExtractSubfolder, "default")

		// Determine download source from URL
		defaultURL := bc.BaseURL("default")
		if strings.Contains(defaultURL, "api.github.com") {
			bc.DownloadSource = DownloadSourceGitHub
		} else {
			bc.DownloadSource = DownloadSourceDirect
		}

		// Forknet extract subfolder (merge)
		forknetSub := parseOSMapFromExtract(jb.Download.ExtractSubfolder, "forknet")
		if len(forknetSub) > 0 {
			bc.ExtractSubfolder = forknetSub
		}
	}

	// Parse alternative download config
	if jb.AltDownload != nil {
		bc.AltBinaryName = jb.AltDownload.Binary
		bc.AltDownloadURLs = parseBaseURLs(jb.AltDownload.Files)
		bc.AltFiles = parseOSFiles(jb.AltDownload.Files, "default")
		bc.AltExtractSubfolder = parseOSMapFromExtract(jb.AltDownload.ExtractSubfolder, "default")
	}

	return bc
}

// parseBaseURLs extracts base_url from each network entry in the files map.
func parseBaseURLs(files map[string]json.RawMessage) map[string]string {
	urls := make(map[string]string)
	for network, raw := range files {
		var entry map[string]string
		if err := json.Unmarshal(raw, &entry); err != nil {
			continue
		}
		if url, ok := entry["base_url"]; ok {
			urls[network] = url
		}
	}
	return urls
}

// parseOSFiles extracts OS -> filename from a specific network entry.
func parseOSFiles(files map[string]json.RawMessage, network string) map[string]string {
	raw, ok := files[network]
	if !ok {
		return nil
	}
	var entry map[string]string
	if err := json.Unmarshal(raw, &entry); err != nil {
		return nil
	}
	result := make(map[string]string)
	for k, v := range entry {
		if k == "base_url" {
			continue
		}
		result[k] = v
	}
	if len(result) == 0 {
		return nil
	}
	return result
}

// parseOSMapFromNetworkMap extracts an OS map from the directories.binary structure.
func parseOSMapFromNetworkMap(networkMap map[string]json.RawMessage, network string) map[string]string {
	raw, ok := networkMap[network]
	if !ok {
		return nil
	}
	var entry map[string]string
	if err := json.Unmarshal(raw, &entry); err != nil {
		return nil
	}
	return entry
}

// parseOSMapFromExtract extracts an OS map from extract_subfolder for a given network.
func parseOSMapFromExtract(subfolder map[string]json.RawMessage, network string) map[string]string {
	raw, ok := subfolder[network]
	if !ok {
		return nil
	}
	var entry map[string]string
	if err := json.Unmarshal(raw, &entry); err != nil {
		return nil
	}
	return entry
}
