#!/usr/bin/env python3
"""Compile and execute focused Swift regression checks on macOS."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="swift-regression-") as directory:
    temporary = Path(directory)
    executable = temporary / "regression-tests"
    subprocess.run([
        "swiftc", "-module-cache-path", str(temporary / "module-cache"),
        str(root / "Homework1/GameRules.swift"), str(root / "tests/main.swift"),
        "-o", str(executable),
    ], check=True)
    subprocess.run([str(executable)], check=True)
