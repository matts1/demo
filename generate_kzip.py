#!/usr/bin/env python3
import hashlib
import json
import pathlib
import shutil
import subprocess

_PATH = pathlib.Path('src/lib.rs')
_DIR = pathlib.Path(__file__).parent
code_content = (_DIR / 'simple/src/lib.rs').read_bytes()
code_digest = hashlib.sha256(code_content).hexdigest()

ret = subprocess.run(['cargo', 'build'], cwd=_DIR / 'simple').returncode
if ret != 0:
    exit(ret)

project_json = {
    "crates": [
        {
            "root_module": str(_PATH),
            "edition": "2024",
            "deps": [],
            "cfg": [],
            "label": "simple label",
            "target": "",
            "source": {
                "include_dirs": [str(_PATH.parent)],
                "exclude_dirs": [],
            },
            "is_workspace_member": True,
        }
    ]
}

project = json.dumps(project_json).encode('utf-8')
project_digest = hashlib.sha256(project).hexdigest()

def write(path: pathlib.Path, content: bytes):
    path.parent.mkdir(exist_ok=True, parents=True)
    path.write_bytes(content)

_OUT = pathlib.Path(_DIR / 'out')
shutil.rmtree(_OUT, ignore_errors=True)

write(_OUT / 'root/files' / code_digest, code_content)
write(_OUT / 'root/files' / project_digest, project)

CORPUS = "chromium"
textproto = f"""
compilation {{
  v_name {{
    corpus: "{CORPUS}"
    language: "rust"
  }}
  required_input {{
    v_name {{
      corpus: "{CORPUS}"
      path: "rust-project.json"
    }}
    info {{
      path: "rust-project.json"
      digest: "{project_digest}"
    }}
  }}
  required_input {{
    v_name {{
      corpus: "{CORPUS}"
      path: "{_PATH}"
    }}
    info {{
      path: "{_PATH}"
      digest: "{code_digest}"
    }}
  }}
  source_file: "{_PATH}"
}}
"""

ps = subprocess.run(
    [
        "gqui",
        "from",
        "textproto:-",
        "proto",
        "kythe.proto.AnalysisRequest",
        "--outfile=rawproto:-"
    ],
    stdout=subprocess.PIPE,
    input=textproto.encode('utf-8'),
)
if ps.returncode != 0:
    exit(ps.returncode)
write(_OUT / 'root/pbunits' / hashlib.sha256(ps.stdout).hexdigest(), ps.stdout)

subprocess.run(
    ['zip', 'example.kzip', '-r', 'root'], cwd=_OUT, check=True
)
