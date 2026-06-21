# Cenozoic Planktonic Foraminifera Morphology Database

A growing, open repository of (semi)landmark configurations, classification
models, and code for the geometric-morphometric analysis of Cenozoic
planktonic foraminifera.

The database is designed to **grow taxon by taxon**. Each contribution adds a
reference set of digitised specimens, a documented landmark scheme, and (where
available) a trained classifier, so that the morphology of additional species
and genera can be added over time under a consistent protocol.

> **Status:** v1 — *Globigerinoides ruber* / *G. elongatus* complex
> (Suárez-Ibarra et al., submitted). Further taxa in progress.

---

## What's in this release

The first module operationalises the revised taxonomy of the *G. ruber*–*G.
elongatus* complex into a fast, reproducible discriminant tool. It distinguishes
*G. elongatus* from *G. ruber* (pooled *albus* + *ruber*) from a 16-(semi)landmark
configuration of the umbilical view, with a leave-one-out accuracy of ~85.6%.

## Repository structure

```
CenoMorph-PF/
├── README.md
├── LICENSE
├── CITATION.cff
├── code/
│   └── apply_lda_model.R        # classify new specimens against a reference set
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

As new taxa are added, each gets its own subfolder under `data/reference/`
(e.g. `data/reference/Trilobatus_sacculifer/`) with the same file conventions.

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

All specimens use the **same 16-(semi)landmark configuration** on the umbilical
view (see `landmarks/landmark_scheme.png`). Digitising must follow this scheme
exactly, in the same order, for the alignment and classification to be valid.

## Specimen metadata

Each specimen should carry, at minimum, the fields in `docs/metadata_template.csv`:
`specimen_ID, taxon, original_label, source (sediment/plankton/museum/literature),
location, age, image_DOI_or_reference, digitiser, date`.
Consistent metadata is what turns a set of files into a usable database.

## How to cite

If you use these data, code, or the model, please cite **both** the paper and
the archived release:

- Suárez-Ibarra et al. (submitted). *[full citation once available].*
- This repository, archived on Zenodo: **[INSERT ZENODO DOI]**

(See `CITATION.cff` for machine-readable citation metadata.)

## Contributing

Contributions of new taxa are welcome. Please open an issue first to agree on
the landmark scheme for the target taxon, then submit reference `.tps` files,
the numbered landmark scheme, and completed metadata. A short contribution guide
will be added as the database grows.

## License

Released under [INSERT LICENSE — e.g. CC-BY 4.0 for data, MIT for code].
Please retain attribution.
