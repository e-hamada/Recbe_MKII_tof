# tof seu fw for recbe-mkii

## Getting started

  Activate Vivado2019.2 (e.g.)
  ```bash
  source /tools/Xilinx/Vivado/2019.2/settings64.sh
  ```

  You must set the license file:
  ```bash
  export XILINXD_LICENSE_FILE="xxx"
  ```

### **Rebuild project (generate .xise, .bit, and others)**

  You can rebuild the project using the following methods:
  
  ---

#### **1. Using the Vivado GUI**
  ```bash
  vivado
  ```
  Then, open the Tcl console and run:
  ```tcl
  source ./reconstruct_project.tcl
  ```

  ---

#### **2. Using batch mode (recommended for automation)**

##### A) Minimal (no `-tclargs`)

```bash
vivado -mode batch -source reconstruct_project.tcl
```

Runs Vivado in batch mode using the script's default settings.

##### B) With arguments (`-tclargs`)

```bash
vivado -mode batch -source reconstruct_project.tcl -tclargs \
  --origin_dir . \
  --project_name recbe-mkii-vivado2019-2 \
  --project_dir ./build/recbe-mkii-vivado2019-2 \
  --run \
  --jobs 8
```

- `--origin_dir`: base directory that contains `src/` (default: `.`)
- `--project_name`: project name (default: set inside the Tcl script)
- `--project_dir`: output directory for the generated `.xpr` (default: `<origin_dir>/<project_name>`)
- `--run`: run `synth_1` and `impl_1` (through bitstream generation)
- `--jobs N`: parallel jobs for Vivado runs (default: `4`)

  ---
