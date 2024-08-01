# mimc-hash

FPGA implementation of MiMC operations.

## Project structure

```
mimc-hash-bn254
├── README.md (This file)
├── src
│   ├── top (Assembled hardware modules)
│   └── base (Hardware modules)
├── tb (Testbenches for hardware modules)
├── data (Hardcoded data files)
└── modelsim (Intel ModelSim project files)
    ├── load.do (Library loader script)
    ├── run_test (Testbench runner script)
    ├── work (NOT pushed into repo)
    └── transcript (NOT pushed into repo)
```

## How to run a Testbench

1.  Switch to the `modelsim` directory:
    ```sh
    cd modelsim
    ```

1.  Use the `run_test` script to run any testbench:
    ```sh
    ./run_test tb_module_name
    ```

## Featured MiMC Design: `AMZ-1`

The relevant project files sufficient for `AMZ-1` are:
```
mimc-hash-bn254
├── data
│   └── mimc_7_91_bn254_round_constants.txt
├── modelsim
│   ├── load.do
│   ├── run_test
└── src
    ├── base
    │   ├── galois_add.v
    │   ├── galois_add_three.v
    │   ├── galois_mult_barrett_sync_v2.v
    │   ├── galois_pow_7_sync_v2.v
    │   ├── mimc_cipher_round_sync_v2.v
    │   ├── mimc_cipher_sync_v2.v
    │   └── mult_256_sync.v
    └── top_mimc_cipher_AMZ1.v
```

To test `AMZ-1`, switch to the `modelsim` directory and launch the `tb_mimc_cipher_sync_v2` testbench:
```sh
cd modelsim
./run_test.py tb_mimc_cipher_sync_v2
```
