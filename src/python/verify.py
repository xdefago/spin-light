#!/usr/bin/python

from pathlib import Path
from subprocess import run, DEVNULL, STDOUT
import sys
import os
import tempfile
import shutil
import platform


if (sys.version_info.major, sys.version_info.minor) < (3, 8):
    raise Exception("Must be using at least Python 3.8")

ROOTDIR = Path(sys.argv[0]).absolute().parent.parent.parent
DESTDIR = ROOTDIR / "output" / "verify"
SPINDIR = ROOTDIR / "src" / "promela"

def cpu_count():
    import multiprocessing
    return multiprocessing.cpu_count()

def number_of_cores():
    return max(1, cpu_count()-1)

PAN_CMD   = "./pan -m100000 -a -f -E -n gathering".split()
CLANG_CMD = (
    f"clang -DMEMLIM=4096 -DXUSAFE -DNOREDUCE -DNCORE={number_of_cores()} -O2 -w -o pan pan.c".split()
        if platform.machine() != "arm64" else
    f"clang -DMEMLIM=4096 -DXUSAFE -DNOREDUCE -O2 -w -o pan pan.c".split()
) # NB: SPIN does not support multi-core on arm64
TRAIL = Path("MainGathering.pml.trail")


Schedulers = (
    "CENTRALIZED",
    "FSYNC",
    "SSYNC",
    "ASYNC_LC_ATOMIC",
    "ASYNC_LC_STRICT",
    "ASYNC_CM_ATOMIC",
    "ASYNC_MOVE_ATOMIC",
    "ASYNC_MOVE_REGULAR",
    "ASYNC_MOVE_SAFE",
    "ASYNC",
    "ASYNC_REGULAR",
    "ASYNC_SAFE",
)

Algorithms = (
    "ALGO_NO_MOVE",
    "ALGO_TO_HALF",
    "ALGO_TO_OTHER",
    "ALGO_VIG_2COLS",
    "ALGO_VIG_3COLS",
    "ALGO_OPTIMAL",
#	"ALGO_TIXEUIL_EXTRA",
#	"ALGO_REGULAR6",
#	"ALGO_REGULAR5",
    "ALGO_REGULAR4",
    "ALGO_FLO_ALGO3EXT",
##	"ALGO_FLO_ALGO3EXT_PRIME",
    "ALGO_3EXT_NONQSS",
    "ALGO_WADA_4EXT",
    "ALGO_WADA_5EXT",
)

def searchComplete(filepath):
    with filepath.open(mode='r') as fp:
        for line in fp.readlines():
            if line.startswith("Warning: Search not completed"):
                return False
        return True

def verify_case(algo, sched):
    filename = f"{algo.lower()}-{sched.lower()}.txt"
    filepath = DESTDIR / filename
    print(f"CASE ({algo}, {sched}) -> {filepath}")
    with filepath.open(mode='w') as fp:
        print(f"CASE ({algo}, {sched}) -> {filepath}", file=fp)			
        run(["spin", "-a", f"-DALGO={algo}", f"-DSCHEDULER={sched}", "MainGathering.pml"], stdout=DEVNULL)
        run(CLANG_CMD)
        run(PAN_CMD, stdout=fp, stderr=STDOUT)
    if TRAIL.exists():
        counterfile = DESTDIR / (filename + ".counter.txt")
        trailfile   = DESTDIR / (filename + ".trail")
        with counterfile.open(mode='w') as counter:
            run(["spin", "-t", f"-DALGO={algo}", f"-DSCHEDULER={sched}", "MainGathering.pml"], stdout=counter, stderr=STDOUT)
        print(f">>>> counter-example written to {counterfile}")
        TRAIL.rename(trailfile)
        return False
    elif searchComplete(filepath):
        print(f"    PASS    ")
        return True
    else:
        print(f"    search incomplete    ")
        return None


if __name__ == "__main__":
    #
    # Ensure the existence of the destination directory
    #
    if not DESTDIR.exists():
        DESTDIR.mkdir(parents=True)
    
    SAVE_CWD = Path.cwd()
    with tempfile.TemporaryDirectory() as tmpdir:
        os.chdir(tmpdir)
        try:  
            #
            # Copy PROMELA code to temp dir
            #
            for prom_file in SPINDIR.glob("*.pml"):
                if prom_file.exists():
                    shutil.copy(src=prom_file, dst=tmpdir)
            #
            # Verification
            #
            outcome = {}
            for algo in Algorithms:
                outcome[algo] = {}
                for sched in Schedulers:
                    outcome[algo][sched] = verify_case(algo, sched)
            #
            # Output to report file
            #
            with (DESTDIR / "summary.txt").open('w') as summary:
                print(" " * 11, end="", file=summary)
                for sched in Schedulers:
                    print(f"{sched[:12]:13}", end="", file=summary)
                print(file=summary)
                for algo in Algorithms:
                    print(f"{algo[5:15]:11}", end="", file=summary)
                    for sched in Schedulers:
                        out = "????" if outcome[algo][sched] is None else "PASS" if outcome[algo][sched] else "--"
                        print(f"{out:13}", end="", file=summary)
                    print(file=summary)
            #
            # Display report file
            # 
            with (DESTDIR / "summary.txt").open('r') as summary:
                for line in summary.readlines():
                    print(line, end="")
        finally:
            os.chdir(SAVE_CWD)
