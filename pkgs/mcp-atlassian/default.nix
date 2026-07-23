{ lib
, buildPythonApplication
, fetchFromGitHub
, fetchPypi
, hatchling
, setuptools
, uv-dynamic-versioning
, # dependencies
  anyio
, atlassian-python-api
, beautifulsoup4
, cachetools
, click
, fakeredis
, fastmcp
, httpx
, keyring
, markdown
, markdownify
, mcp
, pydantic
, python-dateutil
, python-dotenv
, requests
, starlette
, thefuzz
, trio
, truststore
, types-python-dateutil
, unidecode
, urllib3
, uvicorn
, # markdown-to-confluence dependencies
  cattrs
, lxml
, orjson
, pymdown-extensions
, pyyaml
}:

let
  # markdown-to-confluence is not in nixpkgs, build it inline
  markdown-to-confluence = buildPythonApplication rec {
    pname = "markdown_to_confluence";
    version = "0.6.1";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-L1zDAzEChaMIm+AAmnaIpdI4b+yxNUK5riLSKl72DkU=";
    };

    build-system = [ setuptools ];

    dependencies = [
      cattrs
      lxml
      markdown
      orjson
      pymdown-extensions
      pyyaml
      requests
      truststore
    ];

    pythonRemoveDeps = [ "typing-extensions" ];

    pythonRelaxDeps = [ "cattrs" ];

    meta = with lib; {
      description = "Convert markdown to Confluence storage format";
      license = licenses.mit;
    };
  };
in
buildPythonApplication rec {
  pname = "mcp-atlassian";
  version = "0.23.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sooperset";
    repo = "mcp-atlassian";
    rev = "refs/tags/v${version}";
    hash = "sha256-aTiPYMhZwWCjS/S9pZgdb4oFbXyNO7Q/aMUt0bKfSjM=";
  };

  build-system = [ hatchling uv-dynamic-versioning ];

  dependencies = [
    anyio
    atlassian-python-api
    beautifulsoup4
    cachetools
    click
    fakeredis
    fastmcp
    httpx
    keyring
    markdown
    markdown-to-confluence
    markdownify
    mcp
    pydantic
    python-dateutil
    python-dotenv
    requests
    starlette
    thefuzz
    trio
    truststore
    types-python-dateutil
    unidecode
    urllib3
    uvicorn
  ];

  pythonRemoveDeps = [
    "tzdata"
    "types-cachetools"
  ];

  pythonRelaxDeps = [
    "fakeredis"
  ];

  meta = with lib; {
    description = "MCP server for Jira and Confluence";
    homepage = "https://github.com/sooperset/mcp-atlassian";
    license = licenses.mit;
    maintainers = [ maintainers.massimogengarelli ];
    mainProgram = "mcp-atlassian";
  };
}
