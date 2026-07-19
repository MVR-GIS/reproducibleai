# Architecture Decision Record (ADR) 001: Local Agentic R/Python Development and RAG Stack

## Status
Proposed (Drafted for `reproducibleai` package documentation)

## Context & Problem Statement
The United States Army Corps of Engineers (USACE) Civil Works mission requires subject matter experts (SMEs) to develop specialized, multi-repository R and Python packages, maintain automated desktop integrations, and execute analytical workflows (such as Shiny web applications). Simultaneously, staff must analyze extensive, dense government data repositories and manuals to extract authoritative information.

Political and management pressures demand increased development velocity and reduced operational overhead. However, the organization faces substantial headwinds: 

1. **Infrastructure & Integration Gaps:** Centrally provided DoD AI tools (e.g., GenAI.mil) lack repository integration, limiting users to generic clipboard operations. Enterprise enclaves (e.g., Palantir Foundry) are highly sandboxed, isolate teams from agency GitHub Enterprise source code, paywall critical features, and lack mature support for running custom repositories or IDE environments natively. 
2. **Resource Constraints:** Severe budget and funding cuts have drastically reduced or eliminated dedicated contract DevOps and system administration support. 
3. **Governance & Shadow IT Risks:** Staff are increasingly turning to public SaaS frontier models (ChatGPT, Claude) for unclassified (IL2) workflows. Due to a centralized procurement and leadership void, many SMEs pay for these tools out of pocket. This creates tracking, security, fiscal sustainability, and single-point-of-failure vulnerabilities (unreviewed, un-documented "vibe-coded" applications). 

A durable, zero-cost architecture is required to empower a lone technical steward to enforce engineering standards, provide rapid prototyping capabilities to SMEs, and process extensive documentation safely behind the USACE firewall without relying on non-existent DevOps resources.

## Architectural Goals 

* **Zero-DevOps Platform Lifecycle:** Outsource structural engineering to the open-source community by deploying mature, self-contained, pre-integrated software stacks instead of building custom infrastructure. 
* **Closed-Loop Code Validation:** Automate the multi-step cycle of reading codebases, reasoning through features, generating code, executing tests in native language environments, parsing errors, and iterating autonomously. 
* **Unified Context-Aware RAG:** Enable isolated, fully offline document indexing and semantic retrieval over thousands of pages of civil works regulations, modular agency ontologies, and technical scientific literature. 
* **Asymmetric Governance:** Force decentralized accountability by requiring AI-generated validation artifacts (via standard frameworks like `reproducibleai`) prior to authoritative human code review. 

## Requirements & Constraints

* **Compute Constraints:** Execution must operate entirely localized on standard high-performance workstation hardware (typically Intel i9, NVIDIA RTX 4000/5000 GPU architectures, 64GB RAM). 
* **Security & Network Constraints:** All model interactions, data processing, and file reading must occur 100% locally and completely air-gapped from external cloud access when handling sensitive metrics, supporting IL2/IL4 boundaries natively. 
* **Software Constraints:** The host environment is bounded by Windows workstations running **Podman Desktop** under constrained user privileges. 
* **Ecosystem Requirements:** First-class support for multi-repo R packages (`devtools`, `testthat`, `roxygen2`), Python package structures, and reactive Shiny web applications. 

## Design Rationale

### 1. Rejection of Single-Server/Custom Container Meshes 
Building a custom container network running isolated R-kernels or managing intricate API proxy routings was rejected. Without contract DevOps teams, the maintenance burden would rest entirely on a single SME, leading to operational failure. 

### 2. Selection of Open WebUI as the Central Proxy 
Open WebUI was selected to act as the primary frontend and intelligence gateway. It provides out-of-the-box user management, enterprise-grade vector database chunking and parsing (Workspace RAG), and an OpenAI-compatible API emulation layer. This enables it to proxy local models out to developer tools simultaneously.

### 3. Separation of IDE and Browser Modalities 
A two-pronged operational workspace approach is selected to match native developer behavior: 

* **The IDE Workspace (Positron + Continue extension):** Used for linear, real-time code generation, autocomplete, and inline context parsing directly touching local files. 
* **The Browser Workspace (Open WebUI Dashboard):** Used for unstructured knowledge discovery (RAG over PDFs) and complex, agentic multi-step structural refactoring. 

### 4. Direct Workstation Invocation via Posit's `{ellmer}` Package 
Instead of spinning up isolated network execution kernels or containerized R environments (which add infrastructure overhead), this architecture routes execution straight down to the workstation’s host R instance. By leveraging Posit’s `{ellmer}` package via a unified Python shell tool in Open WebUI, the model is granted programmatic R object serialization. This allows it to evaluate package architectures, load libraries (`devtools::load_all()`), and execute tests natively exactly as a human developer would.

## Proposed Architecture

+---------------------------------------------------------------------------------+
|                                  USER BROWSER                                   |
|             (Accesses Open WebUI Dashboard via http://localhost:3000)           |
+---------------------------------------+-----------------------------------------+
                                        |
                                        v
+---------------------------------------------------------------------------------+
|                                 OPEN WEBUI                                      |
|   - Multi-Step Orchestration          - Built-in Vector Storage & Parsing       |
|   - System Prompt Policy Enforcement  - OpenAI-Compatible API Proxy Endpoint    |
+-------------------+-----------------------------------+-------------------------+
                    |                                   |
     (Local Model API Call)               (Triggers Python Subprocess Tool)
                    v                                   v
+-----------------------+               +-----------------------------------------+
|    OLLAMA CONTAINER   |               |         LOCAL WORKSTATION HOST          |
|                       |               |                                         |
|  [Qwen 2.5 Coder 32B] |               |  1. Launches Rscript via system shell   |
|  [DeepSeek R1 32B]    |               |  2. Loads Posit's {ellmer} package      |
+-----------+-----------+               |  3. Scans local repo clone paths        |
|                                       |  4. Runs devtools::test() natively      |
|    (Proxy Endpoint)                   +-----------------------------------------+
            v
+---------------------------------------------------------------------------------+
|                               POSITRON IDE                                      |
|           (Uses Continue Extension Connected to Open WebUI /api Port)           |+---------------------------------------------------------------------------------+

### Infrastructure Definition (`podman-compose.yaml`)

```yaml
services:
  ollama:
    volumes:
      - c:\USACE-AI\ollama:/root/.ollama
    container_name: ollama
    image: ollama/ollama:latest
    restart: unless-stopped
    ports:
      - "11434:11434"

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3000:8080"
    volumes:
      - c:\USACE-AI\open-webui:/app/backend/data
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    depends_on:
      - ollama
```

### Complete Execution Tool Integration Loop
The platform bridges Python to R via the following system execution function registered in the Open WebUI workspace:

```python
import subprocess
import json

class Tools:
    def __init__(self):
        pass

    def run_r_code_via_ellmer(self, r_code: str) -> str:
        """
        Executes a string of R code locally on the workstation computer. 
        Use this tool whenever the user requests to inspect, run tests, verify logic, 
        or modify multi-repository R packages and reactive Shiny web applications.
        :param r_code: The exact string of R code to evaluate in the workspace.
        """
        wrapped_code = f"""
        suppressPackageStartupMessages(library(ellmer))
        tryCatch({{
            result <- eval(parse(text = {json.dumps(r_code)}))
            print(result)
        }}, error = function(e) {{
            cat("R Execution Error: ", e\$message, "\\n")
        }})
        """
        try:
            process = subprocess.run(
                ["Rscript", "-e", wrapped_code],
                capture_output=True,
                text=True,
                timeout=45
            )
            if process.returncode == 0:
                return process.stdout if process.stdout else "Code executed with no returned console tokens."
            else:
                return f"Execution failed:\\nSTDOUT: {process.stdout}\\nSTDERR: {process.stderr}"
        except Exception as e:
            return f"Failed to invoke workstation R runtime: {str(e)}"
```

## Consequences

* **Positive:** Eliminates ongoing procurement friction by bypassing SaaS expenses entirely via open-weight model instances.
* **Positive:** Unlocks true multi-repository awareness and autonomous testing capability that standard commercial extensions cannot fulfill due to context block constraints.
* **Positive:** Keeps 100% of civil engineering assets, source repositories, and data matrices securely contained on host workstations behind the firewall.
* **Negative:** Relies heavily on the compute capacity of individual user machines. Users running lesser configurations than an i9/RTX architecture will experience significant generation latency.
* **Negative:** Code execution commands are passed directly to the host system shell, requiring individual users to maintain authorized file permissions and clean underlying local R installations.
