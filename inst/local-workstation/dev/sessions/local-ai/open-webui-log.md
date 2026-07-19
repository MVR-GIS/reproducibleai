(base) PS C:\workspace\MVR-GIS\reproducibleai> cd inst/local-workstation
(base) PS C:\workspace\MVR-GIS\reproducibleai\inst\local-workstation> launch.ps1 -DebugForeground
[DEBUG] Running Open WebUI in foreground. Ctrl+C to stop.
[DEBUG] If this errors, copy terminal output from here.
Loading WEBUI_SECRET_KEY from file, not provided as an environment variable.
Generating a new secret key and saving it to C:\workspace\MVR-GIS\reproducibleai\inst\local-workstation\.webui_secret_key
Loading WEBUI_SECRET_KEY from C:\workspace\MVR-GIS\reproducibleai\inst\local-workstation\.webui_secret_key     
INFO  [alembic.runtime.migration] Context impl SQLiteImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
WARNI [open_webui.env]

WARNING: CORS_ALLOW_ORIGIN IS SET TO '*' - NOT RECOMMENDED FOR PRODUCTION DEPLOYMENTS.

WARNI [langchain_community.utils.user_agent] USER_AGENT environment variable not set, consider setting it to identify your requests.
C:\Users\B5PMMMPD\AppData\Local\miniforge3\envs\open-webui-gov\Lib\site-packages\pydub\utils.py:170: RuntimeWarning: Couldn't find ffmpeg or avconv - defaulting to ffmpeg, but may not work
  warn("Couldn't find ffmpeg or avconv - defaulting to ffmpeg, but may not work", RuntimeWarning)
C:\Users\B5PMMMPD\AppData\Local\miniforge3\envs\open-webui-gov\Lib\site-packages\open_webui\utils\oauth.py:19: AuthlibDeprecationWarning: authlib.jose module is deprecated, please use joserfc instead.
It will be compatible before version 2.0.0.
  from authlib.jose.errors import BadSignatureError

 ██████╗ ██████╗ ███████╗███╗   ██╗    ██╗    ██╗███████╗██████╗ ██╗   ██╗██╗
██╔═══██╗██╔══██╗██╔════╝████╗  ██║    ██║    ██║██╔════╝██╔══██╗██║   ██║██║
██║   ██║██████╔╝█████╗  ██╔██╗ ██║    ██║ █╗ ██║█████╗  ██████╔╝██║   ██║██║
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║    ██║███╗██║██╔══╝  ██╔══██╗██║   ██║██║
╚██████╔╝██║     ███████╗██║ ╚████║    ╚███╔███╔╝███████╗██████╔╝╚██████╔╝██║
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚══════╝╚═════╝  ╚═════╝ ╚═╝


v0.10.2 - building the best AI user interface.

https://github.com/open-webui/open-webui

INFO:     Started server process [65064]
INFO:     Waiting for application startup.
2026-07-19 13:35:43.142 | INFO     | open_webui.utils.logger:start_logger:214 - GLOBAL_LOG_LEVEL: INFO
2026-07-19 13:35:43.160 | INFO     | open_webui.main:lifespan:336 - Installing external dependencies of functions and tools...
2026-07-19 13:35:43.166 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:439 - No requirements found in frontmatter.
2026-07-19 13:35:43.167 | INFO     | open_webui.utils.automations:scheduler_worker_loop:176 - Scheduler worker started (poll interval: 10s)
2026-07-19 13:37:04.635 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET / HTTP/1.1" 304
2026-07-19 13:37:04.664 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/loader.js HTTP/1.1" 200
2026-07-19 13:37:04.672 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/custom.css HTTP/1.1" 200
2026-07-19 13:37:04.682 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/splash.png HTTP/1.1" 200
2026-07-19 13:37:04.696 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /manifest.json HTTP/1.1" 200
2026-07-19 13:37:04.734 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/splash-dark.png HTTP/1.1" 200
2026-07-19 13:37:04.818 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/favicon.ico HTTP/1.1" 200
2026-07-19 13:37:04.821 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/logo.png HTTP/1.1" 200
2026-07-19 13:37:04.843 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:04.845 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/favicon.png HTTP/1.1" 200
2026-07-19 13:37:04.876 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/v1/auths/ HTTP/1.1" 401
2026-07-19 13:37:04.879 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/v1/auths/ HTTP/1.1" 401
2026-07-19 13:37:04.897 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /_app/immutable/nodes/50.DfL29N9D.js HTTP/1.1" 304
2026-07-19 13:37:04.899 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /_app/immutable/assets/50.Gsrgvs3s.css HTTP/1.1" 304
2026-07-19 13:37:04.902 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /static/favicon.svg HTTP/1.1" 200
2026-07-19 13:37:04.913 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /static/favicon-dark.png HTTP/1.1" 200
2026-07-19 13:37:04.916 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:04.930 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:04.974 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:04.984 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:04.994 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.114 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.120 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.127 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.174 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.181 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.188 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.195 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.214 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.277 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.282 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.296 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.309 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.388 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.408 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.467 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.472 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.478 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.486 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.581 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.608 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.691 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.693 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.694 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.696 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.745 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.778 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.815 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.827 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.839 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.893 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.896 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.897 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.904 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.905 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.906 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:05.938 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:05.942 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.007 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.011 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.027 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.032 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.096 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.112 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.113 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.113 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.122 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.123 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.135 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.140 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.206 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.211 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.219 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.223 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.305 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.310 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.314 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.327 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.332 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.333 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.345 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.350 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.396 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.400 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.408 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.411 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.511 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.515 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.536 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.543 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.545 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.546 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.551 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.553 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.584 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.588 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.602 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.606 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.703 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.724 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.745 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.745 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.747 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.771 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.772 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.784 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.791 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.795 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.801 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.810 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.946 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.951 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:06.974 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:06.975 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.007 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.007 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.027 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.029 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.029 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.044 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.044 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.055 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.142 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.147 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.227 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.229 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.236 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.238 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.240 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.245 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.262 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.265 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.265 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.275 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.343 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.348 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.446 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.450 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.480 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.487 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.489 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.489 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.493 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.519 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.520 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.521 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.556 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.563 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.668 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.673 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.710 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.718 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.720 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.720 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.723 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.731 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.732 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.734 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.777 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.787 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.864 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.868 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.922 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.945 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.959 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.960 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.968 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.969 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.970 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:07.978 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:07.994 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.000 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.054 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.058 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.133 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.137 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.179 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.187 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.188 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.191 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.191 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.198 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.199 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.201 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.245 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.247 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/version HTTP/1.1" 200
2026-07-19 13:37:08.251 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.322 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.327 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.392 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.394 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.402 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.404 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.405 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.406 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.416 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.417 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.440 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.444 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.519 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.522 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.602 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.603 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.611 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.611 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.612 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.619 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.622 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.626 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.631 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.634 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.707 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.712 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.802 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.826 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.828 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.829 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.831 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.833 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.845 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.845 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.847 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.849 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:08.894 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:08.897 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:09.037 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.040 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:09.047 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.047 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.050 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.069 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.070 | INFO     | open_webui.models.auths:authenticate_user:148 - authenticate_user: admin@localhost
2026-07-19 13:37:09.085 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.095 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/v1/folders/ HTTP/1.1" 200
2026-07-19 13:37:09.096 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.118 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/v1/chats/all/tags HTTP/1.1" 200
2026-07-19 13:37:09.133 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/v1/configs/banners HTTP/1.1" 200
2026-07-19 13:37:09.134 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/v1/chats/pinned HTTP/1.1" 200
2026-07-19 13:37:09.156 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/v1/chats/?page=1 HTTP/1.1" 200
2026-07-19 13:37:09.185 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/v1/users/user/settings HTTP/1.1" 200
2026-07-19 13:37:09.191 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/v1/tools/ HTTP/1.1" 200
2026-07-19 13:37:09.194 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.197 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/v1/users/f372fe9b-c008-4b06-a973-997a77981ee0/profile/image HTTP/1.1" 200
2026-07-19 13:37:09.203 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.204 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/v1/folders/ HTTP/1.1" 200
2026-07-19 13:37:09.221 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.227 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.230 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.237 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.240 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.254 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/v1/folders/shared HTTP/1.1" 200
2026-07-19 13:37:09.257 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.258 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/tasks/active/chats HTTP/1.1" 200
2026-07-19 13:37:09.261 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.264 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.268 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.271 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.273 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.275 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.278 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.297 | INFO     | open_webui.routers.ollama:get_all_models:366 - get_all_models()
2026-07-19 13:37:09.297 | INFO     | open_webui.utils.session_pool:get_session:65 - Created shared aiohttp session pool (limit=unlimited, per_host=unlimited, dns_ttl=300)
2026-07-19 13:37:09.298 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.312 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/signin HTTP/1.1" 200
2026-07-19 13:37:09.327 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.332 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.370 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.371 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/v1/folders/shared HTTP/1.1" 200
2026-07-19 13:37:09.372 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.380 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.382 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.386 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.414 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.415 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.422 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.425 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.429 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.457 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.460 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.462 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.468 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.472 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.486 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.489 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/v1/chats/?page=2 HTTP/1.1" 200
2026-07-19 13:37:09.493 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.496 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.498 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.513 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.516 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.521 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.522 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.530 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.530 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.541 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.547 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.562 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.563 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.569 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.576 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.585 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.586 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.593 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.609 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.613 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/models HTTP/1.1" 200
2026-07-19 13:37:09.615 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.631 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.660 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.662 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.667 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/v1/terminals/ HTTP/1.1" 200
2026-07-19 13:37:09.668 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.712 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.720 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.723 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/v1/functions/ HTTP/1.1" 200
2026-07-19 13:37:09.724 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/v1/models/model/profile/image?id=undefined&lang=en-US HTTP/1.1" 302
2026-07-19 13:37:09.725 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.730 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.744 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.750 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.754 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.758 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.760 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.762 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.765 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.768 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.771 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.775 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.779 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.783 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.787 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.793 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.799 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.833 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.842 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.859 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/v1/skills/ HTTP/1.1" 200
2026-07-19 13:37:09.867 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.868 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.876 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.893 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.894 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.900 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.937 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/version/updates HTTP/1.1" 200
2026-07-19 13:37:09.938 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.957 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.970 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:09.971 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:09.972 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.002 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.023 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.025 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.032 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.034 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.038 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.040 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.041 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.049 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.056 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.056 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.061 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.062 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.065 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.067 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.070 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.073 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.077 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.083 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.098 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.101 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.106 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.114 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.116 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.117 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.145 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.148 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.155 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.190 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.207 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.209 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.212 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.217 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.220 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.221 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.226 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.229 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.230 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.233 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.238 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.270 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.273 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.278 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.278 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.302 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.303 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.322 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.327 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.330 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.334 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.335 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.337 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.342 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.346 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.351 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.355 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.358 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.361 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.364 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.366 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.370 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.374 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.377 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.379 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.382 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.384 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.387 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.390 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.395 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.399 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.402 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.404 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.406 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.408 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.411 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.415 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.450 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.459 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.463 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.467 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.472 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.473 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.482 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.484 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.490 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.494 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.497 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.501 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.502 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.506 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.512 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.515 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.523 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.525 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.532 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.538 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.542 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.564 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.570 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.574 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.578 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.595 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.598 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.606 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.616 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.619 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.620 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.624 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.629 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.631 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.633 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.644 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49794 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.650 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64105 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.656 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.658 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.663 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.667 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.668 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.674 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "GET /api/v1/models/model/profile/image?id=qwen2.5-coder:32b-instruct&lang=en-US HTTP/1.1" 302
2026-07-19 13:37:10.676 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "GET /api/config HTTP/1.1" 200
2026-07-19 13:37:10.679 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.698 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.714 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.726 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.732 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.762 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54247 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.764 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64961 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.765 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49740 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:10.769 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60502 - "POST /api/v1/auths/update/timezone HTTP/1.1" 200
2026-07-19 13:37:17.140 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49671 - "GET /static/favicon.png HTTP/1.1" 304
2026-07-19 13:37:17.172 | INFO     | open_webui.routers.ollama:get_all_models:366 - get_all_models()
2026-07-19 13:37:17.187 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49671 - "GET /api/v1/groups/ HTTP/1.1" 200
2026-07-19 13:37:17.222 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49671 - "GET /api/v1/models/list?page=1 HTTP/1.1" 200
2026-07-19 13:37:17.227 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:50714 - "GET /api/models HTTP/1.1" 200
2026-07-19 13:37:17.230 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49671 - "GET /api/v1/models/tags HTTP/1.1" 200
2026-07-19 13:37:18.399 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49671 - "GET /api/v1/tools/list HTTP/1.1" 200
2026-07-19 13:37:18.404 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:49671 - "GET /api/v1/tools/ HTTP/1.1" 200
2026-07-19 13:38:05.579 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:64508 - "GET /_app/version.json HTTP/1.1" 200
2026-07-19 13:39:06.874 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:56470 - "GET /_app/version.json HTTP/1.1" 200
2026-07-19 13:40:07.866 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:52157 - "GET /_app/version.json HTTP/1.1" 200
2026-07-19 13:41:08.875 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:54724 - "GET /_app/version.json HTTP/1.1" 200
2026-07-19 13:42:09.869 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:53751 - "GET /_app/version.json HTTP/1.1" 200