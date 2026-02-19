# zos_cics_software_migration

IBM CICS Transaction Server Migration Automation — CICS TS 6.1 Region Upgrade Project

---

## Project Structure

```
zos_cics_software_migration/
├── JCL/                    # Region startup JCL members (one per CICS region)
│   └── CICSDEV1.jcl        # Startup JCL for CICS Development Region 1
├── PROC/                   # Common reusable JCL procedures
│   └── CICS$61.proc        # CICS TS 6.1 common startup proc (LPAR-portable)
├── SIT/                    # System Initialization Table parameter members
│   └── CDEV1SIT.sit        # Base SIT parameters for CICSDEV1
└── DOC/                    # Architecture and runbook documentation
```

---

## Design Philosophy

### Common Proc: CICS$61

`PROC/CICS$61.proc` is a single, fully parameterized CICS startup procedure
that is designed to be **shared across all LPARs** and **used by any CICS region**.
No LPAR-specific or region-specific hardcoding exists inside the proc.

All region-specific values are supplied as **symbolic parameter overrides** from
the calling JCL. This means:

- One proc in `SYS1.PROCLIB` (or `CICS.PROCLIB`) serves every region on every LPAR.
- Adding a new CICS region requires only a new startup JCL — no proc changes.
- Proc changes (e.g., a new DD name required by a PTF) apply to all regions at once.

### Region Startup JCL: CICSDEV1.jcl

Each region has its own startup JCL that:
1. Calls `CICS$61` via `EXEC PROC=CICS$61`
2. Supplies all region-specific symbolic overrides (RGNNAME, APPLID, SITMBR, HLQs, etc.)
3. Optionally overrides DD statements (e.g., extended `DFHRPL` concatenation)
4. Provides inline `SYSIN` with SIT parameter overrides specific to that region

### SIT Parameters: Three-Layer Override Model

| Layer | Location | Purpose |
|-------|----------|---------|
| 1 (base) | `SIT/CDEV1SIT.sit` → `SDFHPARM(CDEV1SIT)` | Region base SIT values |
| 2 (override) | `//CICSREG.SYSIN DD *` in startup JCL | Runtime overrides, highest priority |
| 3 (proc default) | `//SYSIN DD *` in `CICS$61` | Proc-level defaults (lowest priority) |

---

## Symbolic Parameters in CICS$61

| Parameter  | Default            | Description                                  |
|------------|--------------------|----------------------------------------------|
| `RGNNAME`  | *(required)*       | CICS region name (max 8 chars)               |
| `APPLID`   | *(required)*       | VTAM Application ID (max 8 chars)            |
| `SITMBR`   | `DFHSIT`           | SIT parmlib member name                      |
| `HLQCICS`  | `CICSTS61.CICS`    | CICS 6.1 product library HLQ                 |
| `HLQREGN`  | `CICS.REGIONS`     | Region VSAM dataset HLQ                      |
| `HLQAPP`   | `APP.LOADLIB`      | Application load library HLQ                 |
| `GRPNAME`  | `CICSPLEX1`        | CICSPlex XCF coupling group name             |
| `PLXNAME`  | `PLEX1`            | CICSPlex SM plex name                        |
| `CICSSTOR` | `256M`             | CICS address space storage (JCL REGION=)     |
| `SYSOUT`   | `A`                | SYSOUT class for JES output DDs              |
| `MSGLVL`   | `1`                | CICS message verbosity (0=min, 2=verbose)    |

---

## Region Registry

| JCL Member   | APPLID   | SIT Member | Environment | CICSPlex Group |
|--------------|----------|------------|-------------|----------------|
| CICSDEV1.jcl | CICSDEV1 | CDEV1SIT   | Development | DEVPLXG1       |

---

## Dataset Naming Convention

All region datasets follow this pattern using the supplied HLQ symbolics:

```
CICS System Libraries:    &HLQCICS..SDFHLOAD
                          &HLQCICS..SDFHAUTH
                          &HLQCICS..SDFHPARM   (SIT members)

Region VSAM Datasets:     &HLQREGN..&RGNNAME..GCD
                          &HLQREGN..&RGNNAME..LCD
                          &HLQREGN..&RGNNAME..TEMP
                          &HLQREGN..&RGNNAME..INTRA
                          &HLQREGN..&RGNNAME..AUXTRACE.A/B
                          &HLQREGN..&RGNNAME..TXDUMP.A/B
                          &HLQREGN..&RGNNAME..SLOG.PRIMARY/SECONDARY

Shared Region Datasets:   &HLQREGN..DFHCSD     (may be shared in a CICSPlex)

Application Libraries:    &HLQAPP..LOADLIB
```

---

## Adding a New CICS Region

1. Copy `JCL/CICSDEV1.jcl` to a new member (e.g., `JCL/CICSPRD1.jcl`).
2. Update all region-specific symbolics: `RGNNAME`, `APPLID`, `SITMBR`, `HLQREGN`, `HLQAPP`, `GRPNAME`, `PLXNAME`, `CICSSTOR`.
3. Create a corresponding SIT member (e.g., `SIT/CPRD1SIT.sit`) and upload to `SDFHPARM`.
4. Pre-allocate all required VSAM datasets on the target LPAR.
5. Add the new region to the Region Registry table above.
6. No changes to `CICS$61.proc` are required.

---

## Deployment

The common proc `CICS$61` is deployed to a PROCLIB concatenation accessible on all LPARs:

```
CICS.PROCLIB(CICS$61)     <-- Target PDS member
SYS1.CICSTS61.CICS.SDFHPROCL  <-- IBM-supplied procs (reference)
```

Region startup JCLs are submitted from:
```
CICS.JCLLIB(&RGNNAME)     <-- e.g., CICS.JCLLIB(CICSDEV1)
```

---

## References

- CICS TS 6.1 System Initialization Parameter Reference
- CICS TS 6.1 Installation Guide (SC34-7497)
- CICS TS 6.1 CICS-Supplied Transactions (SC34-7497)
