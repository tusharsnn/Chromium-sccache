import ctypes
import subprocess
import time
import sys
import os
import shutil

from utils import write_github_output


MAX_GITHUB_ACTION_RUN_TIME_IN_SEC = int(os.getenv("MAX_BUILD_TIME", 4*60*60))

# we need to archive artifacts before uploading to avoid upload
# issues. See: https://github.com/actions/upload-artifact#too-many-uploads-resulting-in-429-responses
def archive_dir(path):
    print('Archiving build directory')
    _ = subprocess.run(
        [
            (shutil.which("7z.exe") or "7z.exe"), "a", "-tzip", "{}.zip".format(path),
            "{}".format(path), "-mx=3", "-mtc=on"
        ],
    )

def extract_dir(path):
    print('Extracting build directory')
    _ = subprocess.run(
        [
            (shutil.which("7z.exe") or "7z.exe"), "x", "{}.zip".format(path),
            "-o{}\\..".format(path), # this is parent dir of archived dir
        ],
    )
    os.remove("{}.zip".format(path))

def pause_execution(proc: subprocess.Popen, timeout: int) -> bool:
    is_finished: bool = False
    try:
        proc.wait(timeout)
    except subprocess.TimeoutExpired:
        print("pausing execution of process {}".format(proc.pid))
        for _ in range(3):
            ctypes.windll.kernel32.GenerateConsoleCtrlEvent(1, proc.pid)
            time.sleep(1)
        try:
            proc.wait(10)
            print("waiting for process to finish on its own")
        except:
            proc.kill()
            print("had to kill the build process")
    else:
        is_finished = True

    return is_finished


def _run_build_process_timeout(timeout) -> bool:
    """
    Runs the subprocess with the correct environment variables for building
    """
    chromium_path = os.getenv("CHROMIUM_PATH", "C:\\chromium")
    # Add call to set VC variables

    # cd $env:CHROMIUM_PATH\src 
    # autoninja -C out\Default chrome
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
    job_id = os.getenv("GITHUB_JOB")
    if job_id != "build-1":
        # continuing build from the previous job within the same workflow.
        extract_dir(chromium_path)

    finished = _run_build_process_timeout(
        timeout=MAX_GITHUB_ACTION_RUN_TIME_IN_SEC
    )

    sccache_cache_path = os.getenv("SCCACHE_DIR", "C:\\sccache")
    if finished:
        archive_dir(sccache_cache_path)
        write_github_output("finished", "true")
    else:
        archive_dir(chromium_path)
        archive_dir(sccache_cache_path)
        write_github_output("finished", "false")
    
    return 0
if __name__=="__main__":
    sys.exit(main())
