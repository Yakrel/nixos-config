{ lib, pkgs, ... }:

{
  # Reconcile Oh My Pi agent memory configuration to use the homelab Hindsight
  # engine (LXC 104) while preserving user-managed tokens and model settings.
  home.activation.configureOmpHindsight = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.python3}/bin/python3 <<'PY'
from pathlib import Path

config_dir = Path.home() / ".omp/agent"
config_dir.mkdir(parents=True, exist_ok=True)
config_file = config_dir / "config.yml"

content = config_file.read_text(encoding="utf-8") if config_file.exists() else ""

if "backend: hindsight" not in content:
    hindsight_block = """
memory:
  backend: hindsight
hindsight:
  apiUrl: http://192.168.1.104:8888
  bankId: main
  autoRecall: true
  autoRetain: true
  retainEveryNTurns: 3
  scoping: per-project-tagged
"""
    config_file.write_text((content.rstrip() + "\n" + hindsight_block).lstrip(), encoding="utf-8")
PY
  '';
}
