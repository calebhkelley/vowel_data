# Praat Vowel Extraction Script for Spanish Sociophonetic Analysis

## Overview

This Praat script automatically extracts acoustic measurements from vowels in Spanish speech recordings. It is specifically designed for sociophonetic research examining persona variation (e.g., "gay-sounding" vs. "straight-sounding" speech) but can be adapted for other vowel space analyses.

## Requirements

- **Praat** (version 6.0 or later recommended)
- **Audio files**: WAV format, mono preferred
- **TextGrid files**: Must contain at least two tiers:
  - Tier 1: Word-level annotations
  - Tier 2: Phone-level annotations (vowels marked with IPA symbols)

## File Naming Convention

The script expects files to follow this naming pattern:
```
[SPEAKER]_[PERSONA]_[CONTEXT]_[NUMBER]_mono.TextGrid
[SPEAKER]_[PERSONA]_[CONTEXT]_[NUMBER]_mono.wav
```

Examples:
- `H1_base_narr_1_mono.TextGrid` / `H1_base_narr_1_mono.wav`
- `M3_gay_narr_2_mono.TextGrid` / `M3_gay_narr_2_mono.wav`
- `F2_het_narr_1_mono.TextGrid` / `F2_het_narr_1_mono.wav`

**Persona coding:**
- `_base_` → "baseline"
- `_gay_` → "gay" 
- `_het_` → "straight"

## Input Parameters

When running the script, you'll be prompted to set:

- **Input_directory**: Folder containing TextGrid and WAV files
- **Output_file**: Path for the CSV output file
- **Tier_number**: Phone tier (usually 2)
- **Word_tier_number**: Word tier (usually 1)
- **Vowels**: Space-separated vowel symbols (default: "a e i o u j w")
- **F0_minimum/maximum**: Pitch range (default: 75-300 Hz for male voices)
- **Formant_ceiling**: Maximum formant frequency (default: 5000 Hz)
- **Number_of_formants**: Formants to track (default: 5)
- **Window_length**: Analysis window (default: 0.025 s)
- **Multiple_measurement_points**: Extract formants at 3 timepoints (recommended: true)
- **Include_spectral_measures**: Add spectral moments (optional: true)

## Output

The script generates a CSV file with the following columns:

### Basic Information
- `file`: TextGrid filename
- `speaker`: Speaker ID extracted from filename
- `persona`: Persona condition (baseline/gay/straight)
- `word`: Word containing the vowel
- `vowel`: Vowel symbol

### Temporal Information
- `start_time`: Vowel onset (seconds)
- `end_time`: Vowel offset (seconds) 
- `duration`: Vowel duration (seconds)

### Phonetic Context
- `preceding_phone`: Phone before vowel
- `following_phone`: Phone after vowel

### Fundamental Frequency (F0)
When `Multiple_measurement_points = true`:
- `f0_start`: F0 at 20% into vowel
- `f0_mid`: F0 at vowel midpoint
- `f0_end`: F0 at 80% into vowel
- `f0_min/max/mean/sd`: F0 statistics across vowel

When `Multiple_measurement_points = false`:
- `f0_mid`: F0 at vowel midpoint

### Formants
When `Multiple_measurement_points = true`:
- `f1_start/mid/end`: F1 at 20%, 50%, 80% timepoints
- `f2_start/mid/end`: F2 at 20%, 50%, 80% timepoints
- `f3_mid`: F3 at midpoint

When `Multiple_measurement_points = false`:
- `f1_mid`: F1 at midpoint
- `f2_mid`: F2 at midpoint
- `f3_mid`: F3 at midpoint

### Intensity
- `intensity_max/mean`: Maximum and mean intensity (with multiple points)
- `intensity_mid`: Intensity at midpoint (single point mode)

### Spectral Measures (optional)
When `Include_spectral_measures = true`:
- `cog`: Center of gravity
- `sd_spectrum`: Spectral standard deviation
- `skewness`: Spectral skewness
- `kurtosis`: Spectral kurtosis

## Usage Instructions

1. **Prepare your data**:
   - Ensure TextGrid and WAV files are in the same directory
   - Check that file naming follows the expected convention
   - Verify that vowels are labeled with appropriate IPA symbols

2. **Run the script**:
   - Open Praat
   - Go to `Praat` → `Open Praat script...`
   - Select this script file
   - Click `Run`
   - Fill in the form parameters
   - Click `OK`

3. **Monitor progress**:
   - The script prints progress messages to the Praat Info window
   - Processing time depends on file size and number of files

## Quality Control

The script includes several safeguards:

- **Minimum duration**: Only vowels longer than 30ms are processed
- **Error handling**: Undefined formant/F0 values are set to 0
- **File validation**: Checks for corresponding WAV files before processing
- **Measurement points**: Uses 20% and 80% timepoints to avoid boundary effects

## Typical Applications

This script is designed for research examining:

- **Sociophonetic variation**: Persona-based speech differences
- **Vowel space analysis**: F1/F2 plotting and acoustic space measurements
- **Coarticulatory effects**: Influence of phonetic context on vowel production
- **Prosodic analysis**: F0 patterns across different speech styles
- **Temporal analysis**: Vowel duration differences between conditions

## Recommendations for Spanish

- Use the default vowel set: "a e i o u j w" (includes glides)
- For female speakers, increase `Formant_ceiling` to 5500-6000 Hz
- For children, increase `F0_maximum` and `Formant_ceiling` accordingly
- Consider post-hoc stress assignment based on Spanish phonological rules

## Troubleshooting

**Common issues:**
- **Missing WAV files**: Script will report errors and skip those TextGrids
- **Mismatched tiers**: Check that tier numbers correspond to your annotation scheme
- **No vowels found**: Verify vowel symbols match your TextGrid labels exactly
- **Formant tracking errors**: Adjust `Formant_ceiling` for your speaker population

**Output validation:**
- Check for excessive 0 values (indicates measurement failures)
- Verify F1/F2 values are within expected ranges for Spanish
- Examine duration distributions for outliers

## Citation

If using this script in research, please cite appropriately and acknowledge any modifications made for your specific study.
Kelley, C. H. (2025). Praat vowel extraction script for Spanish sociophonetic analysis [Computer software]. https://github.com/calebhkelley/repository
