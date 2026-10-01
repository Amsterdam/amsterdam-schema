import shutil
import subprocess
import sys

import click


def main() -> None:
    schema_command = shutil.which("schema")
    if schema_command is None:
        raise click.ClickException(
            "The `schema` command from amsterdam-schema-tools is not available on PATH."
        )

    completed = subprocess.run([schema_command, "ingest", *sys.argv[1:]], check=False)
    raise SystemExit(completed.returncode)


if __name__ == "__main__":
    main()
