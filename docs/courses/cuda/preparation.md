# Preparation: Connecting to a GPU on an HPC Machine

This guide describes the general steps to connect to an HPC cluster, set up your working environment, and compile and run a simple CUDA application on a GPU compute node. Most HPC GPU systems follow the same pattern: connect to a **login node** over SSH, stage your files under a **project directory**, request a **GPU compute node** through a scheduler ([SLURM](https://slurm.schedmd.com/pdfs/summary.pdf) in these examples), load the **compiler modules**, then compile and run.

Throughout, MeluXina is used as a concrete example. Replace the hostnames, account/project IDs, partitions, and module names with the values for your own system.

---

## 1. Set up access to the machine

Before anything else, obtain an account and read your site's onboarding documentation. You typically need:

- A user account / username on the system.
- A project (allocation) ID that grants compute time.
- SSH access (often with a key pair and sometimes a non-standard port).

!!! example "MeluXina"
    Read the [getting-access instructions](https://docs.lxp.lu/first-steps/quick_start/), then the connection guide for your OS:

    - [Windows users](https://docs.lxp.lu/first-steps/connecting/)
    - [Linux/Mac users](https://docs.lxp.lu/first-steps/connecting/)

---

## 2. Connect to the login node

Connect over SSH using your username and the login hostname. Many sites use a custom SSH port and let you define an alias in `~/.ssh/config`.

```console
ssh <username>@<login-host> -p <port>
```

If you have set up an SSH alias, connecting is just:

```console
ssh <alias>
```

!!! example "MeluXina"
    For the user `u100490`:

    ```console
    ssh u100490@login.lxp.lu -p 8822
    ```

    With an alias named `meluxina`:

    ```console
    ssh meluxina
    ```

---

## 3. Check your home and project directories

After logging in you land in your home directory. Confirm where you are:

```console
[<username>@login ~]$ pwd
/home/users/<username>
```

Then move to your project directory, where shared course material and allocations usually live:

```console
[<username>@login ~]$ cd /project/home/<project-id>
[<username>@login <project-id>]$ pwd
/project/home/<project-id>
```

!!! example "MeluXina"
    ```console
    [u100490@login02 ~]$ pwd
    /home/users/u100490
    [u100490@login02 ~]$ cd /project/home/p201350
    [u100490@login02 p201350]$ pwd
    /project/home/p201350
    ```

---

## 4. Create your working folder

Create a personal working folder under the project directory so you don't collide with other users. Using `${USER}` names it after your username automatically:

```console
[<username>@login <project-id>]$ mkdir ${USER}
[<username>@login <project-id>]$ cd ${USER}
```

!!! example "MeluXina"
    ```console
    [u100490@login02 p201350]$ mkdir ${USER}
    [u100490@login02 p201350]$ cd u100490
    ```

---

## 5. Copy the course material

Copy the folder containing the examples and source files into your working directory:

```console
[<username>@login <user-dir>]$ cp -r /project/home/<project-id>/CUDA .
[<username>@login <user-dir>]$ cd CUDA/
[<username>@login CUDA]$ ls -lthr
```

!!! example "MeluXina"
    ```console
    [u100490@login03 u100490]$ cp -r /project/home/p201350/CUDA .
    [u100490@login03 u100490]$ cd CUDA/
    [u100490@login03 CUDA]$ pwd
    /project/home/p201350/u100490/CUDA
    [u100490@login03 CUDA]$ ls -lthr
    total 20K
    -rw-r-----. 1 u100490 p201350   51 Mar 13 15:50 module.sh
    drwxr-s---. 2 u100490 p201350 4.0K Mar 13 15:50 Vector-addition
    drwxr-s---. 2 u100490 p201350 4.0K Mar 13 15:50 Unified-memory
    ...
    ```

---

## 6. Reserve a GPU compute node

You are still on the **login node**, which must not be used for computation. Request an interactive GPU node from the scheduler. With SLURM, `salloc` reserves a node for a fixed wall-time:

```console
salloc -A <project-id> --partition=<gpu-partition> --qos <qos> -N 1 -t <HH:MM:SS>
```

The key options:

- `-A` — your project/account ID (who gets billed).
- `--partition` — the GPU partition on your cluster.
- `--qos` — quality-of-service / queue policy.
- `-N` — number of nodes.
- `-t` — wall-clock time limit.

!!! example "MeluXina — reserve a node for a short test"
    ```console
    salloc -A p201350 --partition=gpu --qos default -N 1 -t 01:00:00
    ```

??? "Check that your reservation was allocated"
    ```console
    [u100490@login03 ~]$ salloc -A p201350 --partition=gpu --qos default -N 1 -t 01:00:00
    salloc: Pending job allocation 296848
    salloc: job 296848 queued and waiting for resources
    salloc: job 296848 has been allocated resources
    salloc: Granted job allocation 296848
    salloc: Waiting for resource configuration
    salloc: Nodes mel2131 are ready for job
    ```

You can confirm your running interactive job with `squeue`:

```console
[<username>@<node> ~]$ squeue -u <username>
```

!!! example "MeluXina"
    ```console
    [u100490@mel2131 ~]$ squeue -u u100490
                JOBID PARTITION     NAME     USER    ACCOUNT    STATE       TIME   TIME_LIMIT  NODES NODELIST(REASON)
               304381       gpu interact  u100490    p201350  RUNNING       0:37     01:00:00      1 mel2131
    ```

---

## 7. Locate the CUDA examples

Move into the example folder to verify a simple CUDA program is present. A typical first test lives in a dry-run folder:

```console
[<username>@<node> CUDA]$ cd Dry-run-test/
[<username>@<node> Dry-run-test]$ ls
Hello-world.cu  module.sh
```

---

## 8. Load the compiler modules

HPC systems use environment modules to expose compilers. For CUDA you need an NVIDIA HPC SDK / CUDA toolkit. Load the modules your site provides:

```console
module load <toolchain/environment>
module load <MPI+NVHPC+CUDA module>
export NVCC_APPEND_FLAGS='-allow-unsupported-compiler'
```

Many courses ship a helper script so you don't have to remember the exact module names:

```console
source module.sh
```

!!! example "MeluXina"
    ```console
    module load env/staging/2023.1
    module load OpenMPI/4.1.5-NVHPC-23.7-CUDA-11.7.0
    export NVCC_APPEND_FLAGS='-allow-unsupported-compiler'
    ```

??? "Check that the modules loaded correctly"
    ```console
    [u100490@mel2131 ~]$ module load env/staging/2023.1
    [u100490@mel2131 ~]$ module load OpenMPI/4.1.5-NVHPC-23.7-CUDA-11.7.0
    [u100490@mel2131 ~]$ export NVCC_APPEND_FLAGS='-allow-unsupported-compiler'
    [u100490@mel2131 ~]$ module list

    Currently Loaded Modules:
    1) env/release/2022.1           (S)   6) numactl/2.0.14-GCCcore-11.3.0  11) libpciaccess/0.16-GCCcore-11.3.0  16) GDRCopy/2.3-GCCcore-11.3.0                  21) knem/1.1.4.90-GCCcore-11.3.0
    2) lxp-tools/myquota/0.3.1      (S)   7) CUDA/11.7.0                    12) hwloc/2.7.1-GCCcore-11.3.0        17) UCX-CUDA/1.13.1-GCCcore-11.3.0-CUDA-11.7.0  22) OpenMPI/4.1.5-NVHPC-23.7-CUDA-11.7.0
    3) GCCcore/11.3.0                     8) NVHPC/23.7-CUDA-11.7.0         13) OpenSSL/1.1                       18) libfabric/1.15.1-GCCcore-11.3.0
    4) zlib/1.2.12-GCCcore-11.3.0         9) XZ/5.2.5-GCCcore-11.3.0        14) libevent/2.1.12-GCCcore-11.3.0    19) PMIx/4.2.2-GCCcore-11.3.0
    5) binutils/2.38-GCCcore-11.3.0      10) libxml2/2.9.13-GCCcore-11.3.0  15) UCX/1.13.1-GCCcore-11.3.0         20) xpmem/2.6.5-36-GCCcore-11.3.0

    Where:
        S:  Module is Sticky, requires --force to unload or purge
    ```

---

## 9. Compile and run a simple CUDA application

Compile with `nvcc`, targeting the **compute capability** of the GPU on your node (set with `-arch=compute_XX`). Then run the resulting executable on the compute node:

```console
# compilation
$ nvcc -arch=compute_<XX> Hello-world.cu -o Hello-World-GPU

# execution
$ ./Hello-World-GPU
```

> The architecture flag must match your GPU generation — e.g. `compute_70` (Volta), `compute_75` (Turing / T4), `compute_80` (Ampere A100). Check your site's docs or run `nvidia-smi` to identify the GPU.

!!! example "MeluXina (NVIDIA A100, compute_80 used here)"
    ```console
    # compilation
    $ nvcc -arch=compute_80 Hello-world.cu -o Hello-World-GPU

    # execution
    $ ./Hello-World-GPU
    Hello World from GPU!
    Hello World from GPU!
    Hello World from GPU!
    Hello World from GPU!
    ```

---

## 10. Reserve a node for the hands-on session

For the longer hands-on exercises, reserve a node again with a longer wall-time:

```console
salloc -A <project-id> --partition=<gpu-partition> --qos <qos> -N 1 -t <HH:MM:SS>
```

!!! example "MeluXina"
    ```console
    salloc -A p201350 --partition=gpu --qos default -N 1 -t 02:15:00
    ```

??? "Check that your reservation was allocated"
    ```console
    [u100490@login03 ~]$ salloc -A p201350 --partition=gpu --qos default -N 1 -t 02:15:00
    salloc: Granted job allocation 296848
    salloc: Waiting for resource configuration
    salloc: Nodes mel2131 are ready for job
    ```

---

## 11. Confirm you can access and run the examples

You are now ready for the hands-on exercises. The general workflow inside the `CUDA` folder is: load modules, enter an example directory, compile, and run.

```console
[<username>@<node> CUDA]$ source module.sh
[<username>@<node> CUDA]$ cd Hello-world
[<username>@<node> Hello-world]$ nvcc -arch=compute_<XX> Hello-world.cu -o Hello-World-GPU
[<username>@<node> Hello-world]$ ./Hello-World-GPU
```

!!! example "MeluXina"
    ```console
    [u100490@mel2063 CUDA]$ pwd
    /project/home/p201350/u100490/CUDA
    [u100490@mel2063 CUDA]$ ls
    Dry-run-test  Matrix-multiplication  Profiling      Unified-memory
    Hello-world   module.sh              Shared-memory  Vector-addition
    [u100490@mel2063 CUDA]$ source module.sh
    [u100490@mel2063 CUDA]$ cd Hello-world
    # compilation
    [u100490@mel2063 Hello-world]$ nvcc -arch=compute_80 Hello-world.cu -o Hello-World-GPU
    # execution
    [u100490@mel2063 Hello-world]$ ./Hello-World-GPU
    Hello World from GPU
    ```

---

## Summary

| Step | Generic action | MeluXina example |
|------|----------------|------------------|
| Connect | `ssh <user>@<login-host> -p <port>` | `ssh u100490@login.lxp.lu -p 8822` |
| Go to project | `cd /project/home/<project-id>` | `cd /project/home/p201350` |
| Working folder | `mkdir ${USER} && cd ${USER}` | same |
| Copy material | `cp -r .../CUDA .` | `cp -r /project/home/p201350/CUDA .` |
| Reserve GPU node | `salloc -A <id> --partition=<gpu> --qos <qos> -N 1 -t <time>` | `salloc -A p201350 --partition=gpu --qos default -N 1 -t 01:00:00` |
| Load compilers | `module load ...; source module.sh` | `module load OpenMPI/4.1.5-NVHPC-23.7-CUDA-11.7.0` |
| Compile | `nvcc -arch=compute_<XX> file.cu -o out` | `nvcc -arch=compute_80 Hello-world.cu -o Hello-World-GPU` |
| Run | `./out` | `./Hello-World-GPU` |
