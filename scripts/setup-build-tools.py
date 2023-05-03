import subprocess

def main():
    print("Setting up Depot tools")
    _ = subprocess.run(
        ["pwsh.exe", ".\\scripts\\setup-depot-tools.ps1"],
        check=True
    )
    print('Setting up Sccache')
    _ = subprocess.run(
        ["pwsh.exe", ".\\scripts\\setup-sccache.ps1"],
        check=True
    )

if __name__ == "__main__":
    main()