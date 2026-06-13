# Connecting to Google GPUs & Running CUDA Code (Educational Guide)

A practical guide to accessing free/low-cost GPUs through Google for learning, and to compiling and running CUDA C programs in Google Colab.

---

## Part 1 — Getting GPU Access

### Option A: Google Colab (easiest, recommended for learning)

1. Open [Google Colab](https://colab.research.google.com).
2. Create or open a notebook.
3. Go to **Runtime → Change runtime type**.
4. Set **Hardware accelerator** to **GPU**.
5. Click **Save**.

**Verify the GPU works** (run in a Python cell):

```python
import torch

print(torch.__version__)
print(torch.cuda.is_available())
```

If it returns `True`, the GPU is active.

> **Note:** Free GPU access has usage limits. Switch back to a standard (CPU) runtime when you aren't actively using the GPU so you don't waste your quota.

> **Common error:** `NameError: name 'torch' is not defined` means PyTorch wasn't imported. Run `import torch` first in the same session.

### Option B: Google Cloud education / research credits

If you are a student, teacher, or researcher, you may qualify for:

- **Google Cloud education credits** — redeemable through Google's education credit program.
- **Research credits** — for academic research work.

Once you have credits, you can create a GPU-enabled VM on **Compute Engine** for larger training jobs.

**Recommendation:** Start with Colab for learning PyTorch/TensorFlow. Move to Google Cloud credits + a GPU VM only when you need bigger or longer training runs.

---

## Part 2 — Running CUDA C in Colab

You **cannot** paste CUDA C code directly into a Python cell. A plain C program like `printf("Hello, World!\n");` runs on the CPU, not the GPU. To run on an NVIDIA GPU (e.g., a Tesla T4), you write **CUDA C**, save it to a `.cu` file, compile it with `nvcc`, and execute the result.

### Step 1: Confirm the CUDA compiler is installed

```python
!nvcc --version
```

You should see CUDA version info. If you get `nvcc: command not found`, the compiler isn't available in your environment (see Troubleshooting below).

### Step 2: Write the CUDA source file

Use the `%%writefile` magic to save a `.cu` file from a cell:

```python
%%writefile hello.cu
#include <stdio.h>
#include <cuda_runtime.h>

__global__ void helloFromGPU() {
    printf("Hello World from GPU!\n");
}

int main() {
    helloFromGPU<<<1,1>>>();

    cudaError_t err = cudaDeviceSynchronize();
    if (err != cudaSuccess) {
        printf("CUDA Error: %s\n", cudaGetErrorString(err));
    }

    printf("Hello World from CPU!\n");
    return 0;
}
```

### Step 3: Compile

```python
!nvcc hello.cu -o hello
```

No output means it compiled successfully. Confirm the executable exists:

```python
!ls -l hello
```

### Step 4: Run

```python
!./hello
```

**Expected output:**

```
Hello World from GPU!
Hello World from CPU!
```

### Step 5 (optional): Confirm your GPU

```python
!nvidia-smi
```

Or from Python:

```python
import torch
print(torch.cuda.get_device_name(0))   # e.g. "Tesla T4"
```

---

## Part 3 — Troubleshooting

### Warning about deprecated GPU architectures

```
nvcc warning : Support for offline compilation for architectures prior to
'<compute/sm/lto>_75' will be removed in a future release
(Use -Wno-deprecated-gpu-targets to suppress warning).
```

This is **a warning, not an error** — your program still compiled. It only means newer CUDA versions are dropping support for GPUs older than the Turing generation (SM 7.5). A **Tesla T4 is SM 7.5**, so it is fine.

To suppress the warning:

```python
!nvcc -Wno-deprecated-gpu-targets hello.cu -o hello
```

### `nvcc: command not found`

The CUDA **runtime** may be installed without the **compiler**. Confirm with `!nvcc --version`; if it's missing, you'll need to locate or install the CUDA toolkit in your current Colab environment.

### `./hello` produces no GPU output

Re-run the program and capture the full output — the `cudaDeviceSynchronize()` error check in the code above will print a `CUDA Error:` message that points to the cause.

---

## Quick Reference

| Task | Command |
|------|---------|
| Check GPU available (Python) | `torch.cuda.is_available()` |
| Check CUDA compiler | `!nvcc --version` |
| Write `.cu` file | `%%writefile hello.cu` |
| Compile | `!nvcc hello.cu -o hello` |
| Suppress old-arch warning | `!nvcc -Wno-deprecated-gpu-targets hello.cu -o hello` |
| Run executable | `!./hello` |
| Inspect GPU | `!nvidia-smi` |
| GPU name (Python) | `torch.cuda.get_device_name(0)` |
