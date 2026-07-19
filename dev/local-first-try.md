# Container deployment - TOO PAINFUL

- Too confusing to get windows container networking cofigured correctly.
- See `inst/openwebui/docker-compose.yaml` for compose approach. Older version of Podman Desktop blocked full testing of compose workflow. 
- Attempted direct podman cli creation of containers, but container networking proved too complex on gov workstation. 

Conclusion: Use bare metal install pattern
  - Python and NPM are already approved software and can be used for install
  - Ollama runs much more efficiently bare metal
  - Open WebUI can orchestrate over local pipes much more efficiently

# Bare Metal deployment

## Python
- Install `miniforge3` from App Portal. 
- Follow these instructions to get a working minimal conda environment: https://mvr-gis.github.io/MVR-User-Guide/repo-create-generic-python-repo.html

conda activate analysis

### Why `uv`?
- `uv` Is designed to optimize the management of Python and NPM environments. 
- `uv` It is increasingly becoming the preferred management tool. 
- `uv` Is compatible with older conda environments, but can drastically streamline their management. 
- `uv` It should be submitted to App Portal as key data science infrastructure. 

## NPM
- Install `Node.js`` from App Portal
- Ensure npm is on the user path. If not:

```{ps}
$npmPath = "$env:APPDATA\npm"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$npmPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$npmPath", "User")
    $env:Path += ";$npmPath"
    Write-Host "Success! PATH updated. Please restart your terminal." -ForegroundColor Green
}
```


## Ollama
- Best model performance comes from running on bare metal
- Windows Installer - https://ollama.com/download/OllamaSetup.exe

### Download Windows Installer

```{r}
latest_version_url <- "https://ollama.com/download/OllamaSetup.exe"
latest_version_filename <- basename(file.path(latest_version_url))

downloaded_file <- file.path("C:/workspace", latest_version_filename)

download.file(
  url = latest_version_url,
  destfile = downloaded_file,
  method = "curl",
  mode = "wb",
  extra = "-L --ssl-no-revoke"
)
```

- Run the installer to install locally.
- OR

### Pip Install Ollama

```{ps}
pip install ollama
```

```{ps}
$env:OLLAMA_HOST="0.0.0.0"
ollama serve
```

## Open WebUI

### Python deployment
```{ps}
pip install open-webui
$env:OLLAMA_BASE_URL="http://127.0.0.1:11434"
open-webui serve
```

## View
http://localhost:8080


# Codex  ---------------------------------------------------------------------------
- Determined that codex is a closed ecosystem not compatible with openwebui. Must be used independently. 

# Install codex
```{ps}
npm install -g @openai/codex
```

# Install codex-cli
```{ps}
ollama launch codex --model qwen3.6:latest
```

# Grant permission
```{ps}
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

# Codex config `~/.codex/config.toml`

# =====================================================================
# GLOBAL BASE CONFIGURATION (~/.codex/config.toml)
# =====================================================================
oss_provider = "local-ollama"  
sandbox_mode = "workspace-write"
show_raw_agent_reasoning = true

[shell_environment_policy]
inherit = "all"

[model_providers.local-ollama]
name = "Workstation Ollama Native Engine"
base_url = "http://localhost:11434/v1"
wire_api = "responses"
requires_openai_auth = false


# Run codex in terminal
```{ps}
codex --profile local-dev
```

# Codex MCP (NOTE: Codex can't run as an MCP server - closed ecosystem)

## mcpo
```{ps}
pip install mcpo
mcpo --port 8001 -- codex mcp-server -c model="gpt-oss:20b"
```

