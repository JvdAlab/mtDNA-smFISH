# mtDNA-smFISH

Code and reproducible analysis for:

> **"Single-molecule mitochondrial DNA imaging reveals heteroplasmy dynamics shaped by developmental bottlenecks and selection in vivo"**
> [bioRxiv preprint](https://www.biorxiv.org/content/10.1101/2025.01.24.634671v1)

## Analyses

| Analysis | Description | Report | Source |
|----------|-------------|--------|--------|
| Heteroplasmy variance | NSC progeny heteroplasmy inheritance | [HTML](https://jvdalab.github.io/mtDNA-smFISH/smFISH_heteroplasmy_analysis.html) | [heteroplasmy_analysis/](heteroplasmy_analysis/) |
| Nucleoid imaging | mtDNA nucleoid quantification and colocalization | — | [imaging_analysis/](imaging_analysis/) |

## Repository Structure

```
mtDNA-smFISH/
├── heteroplasmy_analysis/      # NSC progeny heteroplasmy analysis
│   ├── data/                   # Raw data files
│   ├── smFISH_heteroplasmy_analysis.qmd
│   └── README.md               # Detailed instructions
├── imaging_analysis/           # mtDNA nucleoid imaging analysis
│   ├── cp_dp_colocalization.ijm
│   ├── cp_tfam_colocalization.ijm
│   ├── dp_tfam_colocalization.ijm
│   ├── cp_dp_mitochondrial_retention.ijm
│   └── README.md               # Fiji/ImageJ macro usage
└── docs/                       # GitHub Pages rendered reports
```

## Requirements

### Heteroplasmy Analysis
- **R** ≥ 4.4.2
- **Quarto** ≥ 1.4 (https://quarto.org)

### Imaging Analysis
- **Fiji/ImageJ** ≥ 1.53f

See individual analysis directories for specific package dependencies.