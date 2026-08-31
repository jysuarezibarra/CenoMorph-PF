# CenoMorph-PF

A reproducible geometric-morphometric reference database and classifier for the
*Globigerinoides ruber* complex (*albus* and *ruber*)–*G. elongatus*. It provides
the curated landmark reference set, a trained discriminant model, and the R
code to classify new specimens from a 16-landmark configuration of the
umbilical view.

> **Status:** v1 — *Globigerinoides ruber* complex (*albus* and *ruber*) – *G. elongatus*,
> Late Quaternary (Suárez-Ibarra et al., submitted).

---

## What's in this release

This release operationalises the revised taxonomy of the *G. ruber* complex–*G. elongatus*
into a fast, reproducible discriminant and comparative tool. It
distinguishes *G. ruber* complex (pooled *albus* + *ruber*) from *G. elongatus* from a
16-landmark configuration of the umbilical view, with a leave-one-out
accuracy of ~85.6%, based on predominantly Late Quaternary specimens, including
genetic ground-truthing classification.

## Repository structure

```
CenoMorph-PF/
├── README.md
├── LICENSE
├── CITATION.cff
├── IMAGE_SOURCES.md             # provenance + licence of every source image
├── code/
│   └── apply_lda_model.R        # classify new specimens against the reference set
├── data/
│   ├── reference/               # curated, taxonomically revised reference .tps
│   │   ├── G_elongatus.tps
│   │   ├── G_ruber_albus.tps
│   │   └── G_ruber_ruber.tps
│   └── new_samples/             # YOUR images / .tps to be classified
├── landmarks/
│   └── landmark_scheme.png      # the 16-landmark protocol (numbered)
└── docs/
    └── metadata_template.csv    # one row per specimen (see below)
```

## Quick start — classify your own specimens

1. **Install R** (≥ 4.0) and the required packages:

   ```r
   install.packages(c("geomorph", "abind", "MASS", "ggplot2", "dplyr", "ggrepel"))
   ```

2. **Clone or download** this repository.
3. Photograph your specimens in **umbilical view** and place the `.jpg` files in
   `data/new_samples/`.
4. Open `code/apply_lda_model.R`, set the working directory to the repository
   folder (one line, marked in the script), and run it. It will:
   - digitise (Option A) or load (Option B) your specimens,
   - align them with the reference set by Generalised Procrustes Analysis,
   - classify them with the LDA model,
   - write `new_specimen_classifications.csv` and a labelled figure.

## The landmark scheme

All specimens use the **same 16-landmark configuration** on the umbilical
view (see `landmarks/landmark_scheme.png`). Digitising must follow this scheme
exactly, in the same order, for the alignment and classification to be valid.

## Specimen metadata

Each specimen should carry, at minimum, the fields in
`docs/metadata_template.csv`: `specimen_ID, taxon, original_label,
source (sediment/plankton/museum/literature), location, age,
image_DOI_or_reference, digitiser, date`. Consistent metadata is what turns a set
of files into a usable database.

## Image sources and licensing

The reference landmark coordinates were **digitised from specimen images
published in 16 sources** (see [`IMAGE_SOURCES.md`](IMAGE_SOURCES.md) for the full
list with DOIs). Important distinction:

- This repository shares **derived coordinate data** (`.tps` point sets), *not*
  the original images. Coordinates are measurements of the specimens, attributed
  to their source in the metadata.
- Original images remain © their respective publishers. Some sources are open
  access (CC-BY) and some are subscription/publisher-copyright; the split is
  documented in [`IMAGE_SOURCES.md`](IMAGE_SOURCES.md). Anyone wishing to reuse
  the **original images** (rather than the coordinates) should consult the rights
  holder.

## How to cite

If you use these data, code, or the model, please cite **both** the paper and the
archived release:

- Suárez-Ibarra et al. (submitted).
- This repository, archived on Zenodo [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22212946.svg)](https://doi.org/10.5281/zenodo.22212946)
.

(See `CITATION.cff` for machine-readable citation metadata.)

## License

- **Code** (`code/`): released under the [MIT License](LICENSE).
- **Data** (`data/`, landmark coordinates) and documentation: released under
  [Creative Commons Attribution 4.0 (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).

Please retain attribution. Note that the **original specimen images** are not
distributed here and remain © their respective publishers (see
[`IMAGE_SOURCES.md`](IMAGE_SOURCES.md)).
