import subprocess
import os
from utils import print_immediate

def main():
    print_immediate("Setting up Depot tools")
    _ = subprocess.run(
        ["pwsh.exe", ".\\scripts\\setup-depot-tools.ps1"],
        check=True
    )
    print_immediate('Setting up Sccache')
    _ = subprocess.run(
        ["pwsh.exe", ".\\scripts\\setup-sccache.ps1"],
        check=True
    )
    print_immediate("Fetching dependencies")
    depot_tools_path = os.getenv("DEPOT_TOOLS_PATH", "C:\\depot_tools")
    _ = subprocess.run(
        ["{}\\gclient.bat".format(depot_tools_path)],
        check=True
    )

if __name__ == "__main__":
    main()
