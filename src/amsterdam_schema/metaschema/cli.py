import shutil
import subprocess  # nosec

import click

REMOTE_SERVER = "https:\/\/schemas\.data\.amsterdam\.nl"  # noqa W605


@click.group()  # type: ignore[misc]
def metaschema() -> None:
    """Command line utility for working with metaschemas."""


@metaschema.command("create")  # type: ignore[misc]
@click.argument("base_version", required=True)  # type: ignore[misc]
@click.argument("target_version", required=True)  # type: ignore[misc]
def create(base_version: str, target_version: str) -> None:
    """Create a new metaschema with TARGET_VERSION version based on the BASE_VERSION.

    Also automatically update the refs to the new version.

    Both arguments should include the `v`, i.e. `v3.2.0`, not `3.2.0`.
    """
    shutil.copytree(f"schema@{base_version}", f"schema@{target_version}")
    subprocess.run(
        f"sed -i s/{base_version}/{target_version}/g schema@{target_version}/{{,**/}}*.json",
        shell=True,
        executable="/bin/bash",
    )  # nosec
    # add symlink
    subprocess.run(
        f"ln -s ../../schema@{target_version}/ ./src/amsterdam_schema/schema@{target_version}",
        shell=True,
        executable="/bin/bash",
    )  # nosec


@metaschema.command("diff")  # type: ignore[misc]
@click.argument("base_version", required=True)  # type: ignore[misc]
@click.argument("target_version", required=True)  # type: ignore[misc]
@click.option(
    "--show-all",
    is_flag=True,
    default=False,
    help="Also show changes that include the version number",
)  # type: ignore[misc]
def diff(base_version: str, target_version: str, show_all: bool) -> None:
    """Output the git diff between two metaschema versions BASE_VERSION and TARGET_VERSION.

    Both arguments should include the `v`, i.e. `v3.2.0`, not `3.2.0`.

    Ignores the lines that include either of the versions, to keep it clean.
    """
    regex = f"@({base_version}|{target_version})"
    command = f"git diff --no-index schema@{base_version} schema@{target_version}"
    if not show_all:
        command += f" -I{regex!r}"
    subprocess.run(
        command,
        shell=True,
        executable="/bin/bash",
    )  # nosec


@metaschema.group("refs")  # type: ignore[misc]
def refs() -> None:
    """Change the refs of the metaschema and optionally dataset."""


@refs.command("local")  # type: ignore[misc]
@click.argument("version", required=True)  # type: ignore[misc]
@click.argument("dataset", required=False)  # type: ignore[misc]
@click.option(
    "--docker",
    is_flag=True,
    default=False,
    help="Use the docker local ref: host.docker.internal, "
    "helpful when accessing from local DSO container.",
)  # type: ignore[misc]
@click.option(
    "--port", default="8000", help="Port at which the local server is serving the schemas."
)  # type: ignore[misc]
def local_refs(version: str, dataset: str, docker: bool, port: str) -> None:
    """Set the refs of the specified metaschema VERSION to local.

    VERSION should include the `v`, i.e. `v3.2.0`, not `3.2.0`

    The optional DATASET argument also sets the refs in the dataset.
    """
    local_server = "host.docker.internal" if docker else "localhost"
    subprocess.run(
        f"sed -i 's/{REMOTE_SERVER}/http:\/\/{local_server}:{port}/g' "  # noqa W605
        f"schema@{version}/{{,**/}}*.json",
        shell=True,
        executable="/bin/bash",
    )  # nosec
    if dataset:
        subprocess.run(
            f"sed -i 's/{REMOTE_SERVER}/http:\/\/{local_server}:{port}/g' "  # noqa W605
            f"datasets/{dataset}/{{,**/}}*.json",
            shell=True,
            executable="/bin/bash",
        )  # nosec


@refs.command("remote")  # type: ignore[misc]
@click.argument("version", required=True)  # type: ignore[misc]
@click.argument("dataset", required=False)  # type: ignore[misc]
def remote_refs(version: str, dataset: str) -> None:
    """Set the refs of the specified metaschema VERSION to remote.

    The optional DATASET argument also sets the refs in the dataset.
    """
    local_servers = ["localhost", "host.docker.internal"]
    for local_server in local_servers:
        # only one of these servers will actually be the case.
        subprocess.run(
            f"sed -i 's/http:\/\/{local_server}:[0-9]*/{REMOTE_SERVER}/g' "  # noqa W605
            f"schema@{version}/{{,**/}}*.json",
            shell=True,
            executable="/bin/bash",
        )  # nosec
    if dataset:
        for local_server in local_servers:
            subprocess.run(
                f"sed -i 's/http:\/\/{local_server}:[0-9]*/{REMOTE_SERVER}/g' "  # noqa W605
                f"datasets/{dataset}/{{,**/}}*.json",
                shell=True,
                executable="/bin/bash",
            )  # nosec


@metaschema.command("drop")  # type: ignore[misc]
@click.argument("version", required=True)  # type: ignore[misc]
def drop(version: str) -> None:
    """Delete a metaschema version.

    Uses shutil.rmtree, as discarding git changes keeps the folders around.
    """
    shutil.rmtree(f"schema@{version}")
    # remove symlink
    subprocess.run(
        f"rm ./src/amsterdam_schema/schema@{version}", shell=True, executable="/bin/bash"
    )  # nosec


def main() -> None:
    metaschema()


if __name__ == "__main__":
    main()
