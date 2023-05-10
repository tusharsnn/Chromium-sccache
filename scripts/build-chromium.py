import ctypes
import subprocess
import time
import sys
import os
import shutil
from pathlib import Path

from utils import write_github_output, print_immediate


MAX_GITHUB_ACTION_RUN_TIME_IN_SEC = int(os.getenv("MAX_BUILD_TIME", 5*60))
print_immediate("Max Build Time (mins): {}".format(MAX_GITHUB_ACTION_RUN_TIME_IN_SEC // 60))

# we need to archive artifacts before uploading to avoid upload
# issues. See: https://github.com/actions/upload-artifact#too-many-uploads-resulting-in-429-responses
def archive_dir(srcpaths, target_zip, listdir = False):
    print_immediate(
        'Archiving: {}'.format(" ".join(srcpaths))
    )
    if listdir:
        # syntax: pwsh -c ls <dir1>,<dir2>, ...
        # ensure no trailing comma in the list of paths
        _ = subprocess.run(
            ["pwsh.exe", "-c", "ls", ",".join(srcpaths).strip(",")] 
        )
    _ = subprocess.run(
        [
            (shutil.which("7z.exe") or "7z.exe"), "a", "-tzip", target_zip,
            *srcpaths, "-mx=3", "-mtc=on"
        ],
    )

def extract_dir(filepath, targetpath):
    print_immediate('Extracting: {}'.format(filepath)) 
    _ = subprocess.run(
        [
            (shutil.which("7z.exe") or "7z.exe"), "x", filepath,
            "-o{}".format(targetpath), # this is parent dir of archived dir
        ],
    )
    os.remove("{}".format(filepath))

def pause_execution(proc: subprocess.Popen, timeout: int) -> bool:
    is_finished: bool = False
    try:
        proc.wait(timeout)
    except subprocess.TimeoutExpired:
        print_immediate("pausing execution of process {}".format(proc.pid))
        for _ in range(3):
            ctypes.windll.kernel32.GenerateConsoleCtrlEvent(1, proc.pid)
            time.sleep(1)
        try:
            print_immediate("\nwaiting for process to finish on its own")
            proc.wait(10)
        except:
            proc.kill()
            print_immediate("\nhad to kill the build process")
    else:
        is_finished = True

    return is_finished


def _run_build_process_timeout(timeout) -> bool:
    """
    Runs the subprocess with the correct environment variables for building
    """
    chromium_path = os.getenv("CHROMIUM_PATH", "C:\\chromium")
    # Add call to set VC variables

    with subprocess.Popen(
            (
                (shutil.which("autoninja.bat") or "autoninja.bat"), 
                "-C", 
                "out\\Default", 
                "chrome"
            ),
            encoding="UTF-8",
            creationflags=subprocess.CREATE_NEW_PROCESS_GROUP, 
            cwd="{}\\src".format(chromium_path)
        ) as proc:
        return pause_execution(proc, timeout=timeout)
        

def main():
    chromium_path = os.getenv("CHROMIUM_PATH", "C:\\chromium")
    artifact_path = os.getenv("ARTIFACT_PATH", "C:\\artifacts")
    sccache_cache_path = os.getenv("SCCACHE_DIR", "C:\\sccache")
    depot_tools_path = os.getenv("DEPOT_TOOLS_PATH", "C:\\depot_tools")
    sccache_tool = os.getenv("SCCACHE_TOOL_PATH", 'C:\\sccache-v0.4.2-x86_64-pc-windows-msvc')

    job_id = os.getenv("GITHUB_JOB")
    if job_id != "build-1":
        # extract partial-build.zip into 'C:\'
        extract_dir(
            filepath=os.path.join(artifact_path, "partial-build.zip"), 
            targetpath=Path(chromium_path).drive
        )
        extract_dir(
            # filepath is $ARTIFACT_PATH\sccache.zip
            filepath=os.path.join(artifact_path, "sccache.zip"),
            # targetpath is parent dir of $SCCACHE_DIR
            targetpath=Path(sccache_cache_path).drive
        )

    finished = _run_build_process_timeout(
        timeout=MAX_GITHUB_ACTION_RUN_TIME_IN_SEC
    )

    archive_dir(
        srcpaths=[sccache_cache_path],
        target_zip=os.path.join(artifact_path, "sccache.zip"),
    )
    if not finished:
        archive_dir(
            srcpaths=[depot_tools_path, chromium_path, sccache_tool],
            target_zip=os.path.join(artifact_path, "partial-build.zip")
        )
        write_github_output("finished", "false")
    else: 
        write_github_output("finished", "true")
    
    return 0

if __name__=="__main__":
    sys.exit(main())
