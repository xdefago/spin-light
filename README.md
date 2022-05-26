# spin-light

This project contains a verification model written in PROMELA (SPIN model checker) to verify rendezvous algorithms of two robots equipped with lights.

The exact context is not detailed here but can be found in the prolific literature on the topic of so-called "luminous robots".


## Modeling

### Execution parameters

* Algorithms:
  * `ALGO_NO_MOVE`
  * `ALGO_TO_HALF`
  * `ALGO_TO_OTHER`
  * `ALGO_VIG_2COLS`
  * `ALGO_VIG_3COLS`
  * `ALGO_OPTIMAL`
  * `ALGO_FLO_ALGO3EXT`
  * `ALGO_3EXT_NONQSS`
  * `ALGO_WADA_4EXT`
  * `ALGO_WADA_5EXT`
  * `ALGO_REGULAR4`
  * `ALGO_REGULAR5`
  * `ALGO_REGULAR6`
* Models:
  * `CENTRALIZED`
    Each robot completes a full execution cycle in mutual exclusion
  * `FSYNC`
    Both robots complete their full execution cycle in parallel.
  * `SSYNC`
    At each "round" either both robots execute their full execution cycle in parallel or either one of them executes it in mutual exclusion.
  * `ASYNC`
    A robot is chosen non-deterministically to execute a single step in its activation cycle.
  * `ASYNC_REGULAR`
    Same as `ASYNC` but with **regular** "register semantics"
  * `ASYNC_SAFE`
    Same as `ASYNC` but with **safe** "register semantics"
  * `ASYNC_MOVE_ATOMIC`
    Same as `ASYNC` but the two move steps execute atomically
  * `ASYNC_MOVE_REGULAR`
    Same as `ASYNC_MOVE_ATOMIC` but with **regular** "register semantics"
  * `ASYNC_MOVE_SAFE`
    Same as `ASYNC_MOVE_ATOMIC` but with **safe** "register semantics"
  * `ASYNC_LC_ATOMIC`
    Same as `ASYNC` but the two steps `LOOK` and `COMPUTE` execute as one atomic step
  * `ASYNC_LC_STRICT`
    Same as `ASYNC_LC_ATOMIC` but the combined LC step of both robots never execute simultaneously 
  * `ASYNC_CM_ATOMIC`
    Same as `ASYNC` but the steps of `COMPUTE` and `MOVE` execute as one atomic step

* Register Semantics: <br>
  If a `LOOK` occurs during the other robot's `COMPUTE` (between `BEGIN_COMPUTE` and `END_COMPUTE`), then the color being read depends on register semantics, as follows:
  * `SAFE` means that any color can be read from the color domain assumed by the algorithm.
  * `REGULAR` means that either one of the original and new color can be read.
  * `ATOMIC` (the default) means that only the original color is read until `END_COMPUTE`, after which only the new color is read.

### State types

* Activation steps: `LOOK`, `BEGIN_COMPUTE`, `END_COMPUTE`, `BEGIN_MOVE`, `END_MOVE`
* Colors: `BLACK`, `WHITE`, `RED`, `YELLOW`, `GREEN`; can also use consecutive numbers starting from zero.


## Verification

### Verification script

The python script `src/python/verify.py` performs an exhaustive verification for all models (schedulers) and most algorithms. The script is simply run from the terminal without arguments. Running the script will create a directory `output/verify` at the root of this project, with report files from the verification of each case, as follows:
* `algo_<algorithm name>.txt` contains the output of the verification (number of states, memory, etc.).
* `algo_<algorithm name>.txt.trail` contains the description of a counter-example as output by SPIN to be used by generic tools.
* `algo_<algorithm name>.txt.counter.txt` contains a textual description of the counter-example that can be made more readable by executing the command
    ~~~
    egrep '(<<<|CONF|STEP)' algo_<algorithm name>.txt.counter.txt
    ~~~
All of the results (pass or fail) are summarized in the file `output/verify/summary.txt`


### Verification commands

- commands to verify liveness

~~~
% spin -a -DALGO=ALGO_OPTIMAL -DSCHEDULER=ASYNC MainGathering.pml
% clang -DMEMLIM=2048 -DXUSAFE -DNOREDUCE -O2 -w -o pan pan.c
% ./pan -m100000 -a -f -E -n gathering
~~~

- command to output a counter-example

~~~
% spin -t MainGathering.pml
~~~

- command to obtain a more compact trace

~~~
% spin -t MainGathering.pml | egrep '(<<<|CONF|STEP)'
~~~

## Project structure

* `src/promela`: source code of the SPIN model. The detailed structure is explained below.
* `src/python`: helper code
    * `verify.py`: runs the verification for known algorithms under all schedulers; edit the code to change the list of algorithms / schedulers. NB: pan will not work in multi-core mode on Apple M1.

### Promela code structure

This explains the code in `src/promela`

* `Algorithms.pml` collection of the known rendez-vous algorithms.
* `MainGathering.pml` entry point of the verification; initialization of the system and robots states.
* `Robots.pml` definition of the robots, the LCM cycle and its operations, and the movement resolution.
* `Schedulers.pml` definitions of each scheduler: SSYNC, ASYNC, ...
* `Types.pml` definitions of the main types (colors, observations, etc..)
