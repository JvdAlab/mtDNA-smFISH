# mtDNA Nucleoid Imaging Analysis

Fiji/ImageJ macros for quantifying mitochondrial DNA (mtDNA) nucleoids and their spatial relationships within the mitochondrial network from single-molecule FISH imaging data.

## Overview

These macros enable detection and colocalization analysis of:

- **CP** — Control mtDNA probe
- **dP** — Deletion mtDNA probe
- **T20** — TOMM20 mitochondrial network marker
- **TFAM** — Mitochondrial transcription factor A (nucleoid-associated protein)

All analyses are performed on **2D maximum-intensity projections** from confocal or structured illumination microscopy (SIM) data.

## Macros

| Macro | Description |
|-------|-------------|
| [cp_dp_colocalization.ijm](cp_dp_colocalization.ijm) | CP–dP colocalization within TOMM20⁺ mitochondrial regions |
| [cp_tfam_colocalization.ijm](cp_tfam_colocalization.ijm) | CP–TFAM association within the mitochondrial network |
| [dp_tfam_colocalization.ijm](dp_tfam_colocalization.ijm) | dP–TFAM association within the mitochondrial network |
| [cp_dp_mitochondrial_retention.ijm](cp_dp_mitochondrial_retention.ijm) | CP/dP nucleoid distribution: total cellular count vs. mitochondrial retention |

## Image Requirements

Input images must be:

- **4-channel fluorescence** images containing:
  1. **Channel 1:** CP
  2. **Channel 2:** dP
  3. **Channel 3:** TOMM20 / T20
  4. **Channel 4:** TFAM

- Acquired as **z-stacks** and then **maximum-intensity projected**
- Regions of interest (ROIs) drawn manually to isolate a cell or mitochondrial network

## Software Requirements

- **Fiji / ImageJ** (version ≥ 1.53f recommended)
- Built-in functions only (no external plugins required)

## Processing Pipeline

All macros share a common preprocessing strategy:

### Signal Preprocessing (CP and dP)

1. Background subtraction (rolling ball radius = 50 px)
2. Gaussian blur (σ = 2)
3. Laplacian deconvolution (5×5 kernel, center weight 24, surrounding -1)
4. Minimum filter (radius = 2 px)
5. Final Gaussian blur (σ = 2)

### T20 Mitochondrial Masking

1. Background subtraction (50 px rolling ball)
2. Contrast enhancement (0.35% saturation)
3. Gaussian blur (σ = 2)
4. Otsu thresholding to create mitochondrial mask

### TFAM Mask

1. Background subtraction (20 px rolling ball)
2. Contrast enhancement and Gaussian blur (σ = 2)
3. Otsu thresholding

### Spot Detection

| Channel | Detection Method |
|---------|------------------|
| CP      | Find Maxima (prominence = 15) |
| dP      | Find Maxima (prominence = 12) |
| TFAM    | Mask-based membership only |

### Colocalization Logic

- **CP–dP**: dP spot ≤ 3 pixels from CP spot
- **CP/dP–TFAM**: spot inside TFAM ∩ T20 mask

## Usage

1. Open a **maximum projected 4-channel image** in Fiji
2. Draw ROI(s) to isolate a cell or mitochondrial region
3. Run the desired macro via `Plugins > Macros > Run...`
4. When prompted, **adjust thresholds manually** for each channel
5. Results will appear in the ImageJ Results table

## Output Metrics

### cp_dp_colocalization.ijm

Quantifies colocalization between control (CP) and deletion-bearing (dP) mtDNA within mitochondria.

**Colocalization rule**: dP spot located within 3 pixels of CP spot centroid

**Outputs**:
- Total CP nucleoids
- Total dP nucleoids
- Colocalized dP spots
- % dP–CP colocalization
- Spot overlays for visual QC

### cp_tfam_colocalization.ijm

Quantifies association of control mtDNA (CP) nucleoids with TFAM within mitochondria.

**Association rule**: `CP ∩ T20 ∩ TFAM`

**Outputs**:
- Total CP nucleoids in mitochondria
- CP–TFAM positive nucleoid count
- % CP–TFAM association
- Overlay image for QC

### dp_tfam_colocalization.ijm

Quantifies association of deletion-bearing mtDNA (dP) nucleoids with TFAM.

**Association rule**: `dP ∩ T20 ∩ TFAM`

**Outputs**:
- Total dP nucleoids in mitochondria
- dP–TFAM positive nucleoids
- % dP–TFAM association
- Optional overlays for QC

### cp_dp_mitochondrial_retention.ijm

Quantifies whole-cell vs. mitochondrial distribution of CP and dP nucleoids.

**Retention metrics**:
```
% CP_mito = (CP in T20) / (total CP) × 100
% dP_mito = (dP in T20) / (total dP) × 100
```

**Outputs**:
- Total CP spots
- CP spots within mitochondrial mask
- Total dP spots
- dP spots within mitochondrial mask
- Mitochondrial retention % for each probe

## Biological Rationale

Mitochondrial nucleoids contain mtDNA and associated proteins. Alterations in nucleoid number, distribution, and TFAM association are hallmarks of disrupted mitochondrial genetics.

This analysis enables quantification of:
- mtDNA deletion probe localization
- CP vs. dP colocalization
- TFAM association with nucleoids
- Proportion of nucleoids retained within mitochondria

## Citation

If you use these macros in published work, please cite:

> **"Single-molecule mitochondrial DNA imaging reveals heteroplasmy dynamics shaped by developmental bottlenecks and selection in different organs in vivo"**
> [bioRxiv preprint](https://www.biorxiv.org/content/10.1101/2025.01.24.634671v1)
