# Parameters for male Sevillian Spanish speakers
form Process TextGrid files in a folder
  sentence Input_directory /Users/calebkelley/Research_Data/Narrative_may2025
  sentence Output_file /Users/calebkelley/Research_Data/Output_may2025/vowel_data_test_may22.csv
  integer Tier_number 2
  integer Word_tier_number 1
  sentence Vowels a e i o u j w
  real F0_minimum 75
  real F0_maximum 300
  real Formant_ceiling 5000
  integer Number_of_formants 5
  real Window_length 0.025
  boolean Multiple_measurement_points 1
  boolean Include_spectral_measures 1
endform

# Format vowels string properly
vowels$ = " " + vowels$ + " "
vowels$ = replace$(vowels$, "  ", " ", 0)

# Create and write header to output file - UPDATED HEADER
if multiple_measurement_points
  writeFileLine: output_file$, "file,speaker,persona,word,vowel,start_time,end_time,duration,preceding_phone,following_phone,f0_start,f0_mid,f0_end,f0_min,f0_max,f0_mean,f0_sd,f1_start,f1_mid,f1_end,f2_start,f2_mid,f2_end,f3_mid,intensity_max,intensity_mean,cog,sd_spectrum,skewness,kurtosis"
else
  writeFileLine: output_file$, "file,speaker,persona,word,vowel,start_time,end_time,duration,preceding_phone,following_phone,f0_mid,f1_mid,f2_mid,f3_mid,intensity_mid"
endif

# Get all TextGrid files in the directory
Create Strings as file list: "textgrid_list", input_directory$ + "/*.TextGrid"
numberOfFiles = Get number of strings

# Process each TextGrid file
for fileIndex from 1 to numberOfFiles
  selectObject: "Strings textgrid_list"
  textgrid_file$ = Get string: fileIndex
  full_textgrid_path$ = input_directory$ + "/" + textgrid_file$
  
  # Extract speaker ID from filename (assumes format like "H1_base_narr_1_mono.TextGrid")
  speaker$ = left$(textgrid_file$, index(textgrid_file$, "_") - 1)
  
  # Determine persona based on filename
  if index(textgrid_file$, "_base_") > 0
    persona$ = "baseline"
  elsif index(textgrid_file$, "_gay_") > 0
    persona$ = "gay"
  elsif index(textgrid_file$, "_het_") > 0
    persona$ = "straight"
  else
    persona$ = "unknown"
  endif
  
  # Find corresponding sound file
  sound_file$ = replace$(full_textgrid_path$, ".TextGrid", ".wav", 0)
  
  # Check if sound file exists
  if fileReadable(sound_file$)
    # Open files
    Read from file: full_textgrid_path$
    textgrid = selected("TextGrid")
    Read from file: sound_file$
    sound = selected("Sound")
    
    # Create analysis objects
    selectObject: sound
    To Pitch: 0, f0_minimum, f0_maximum
    pitch = selected("Pitch")
    
    selectObject: sound
    To Formant (burg): 0, number_of_formants, formant_ceiling, window_length, 50
    formant = selected("Formant")
    
    selectObject: sound
    To Intensity: 100, 0, "yes"
    intensity = selected("Intensity")
    
    # Extract measurements for each vowel
    selectObject: textgrid
    nIntervals = Get number of intervals: tier_number
    
    for i from 1 to nIntervals
      selectObject: textgrid
      label$ = Get label of interval: tier_number, i
      
      # Check if the interval is a vowel
      if index(vowels$, " " + label$ + " ") > 0
        startTime = Get start time of interval: tier_number, i
        endTime = Get end time of interval: tier_number, i
        duration = endTime - startTime
        
        # Only process vowels of reasonable duration (avoid very short segments)
        if duration > 0.03
          midpoint = startTime + duration/2
          startpoint = startTime + duration * 0.2
          endpoint = endTime - duration * 0.2
          
          # Find the word this vowel belongs to (from Tier 1)
          selectObject: textgrid
          word_interval = Get interval at time: word_tier_number, midpoint
          word_label$ = Get label of interval: word_tier_number, word_interval
          
          # Get preceding and following phones
          preceding_phone$ = ""
          following_phone$ = ""
          
          # Get preceding phone (from previous interval)
          if i > 1
            preceding_phone$ = Get label of interval: tier_number, i-1
          endif
          
          # Get following phone (from next interval)
          if i < nIntervals
            following_phone$ = Get label of interval: tier_number, i+1
          endif
          
          # Get F0 measurements
          selectObject: pitch
          f0_mid = Get value at time: midpoint, "Hertz", "Linear"
          if f0_mid = undefined
            f0_mid = 0
          endif
          
          if multiple_measurement_points
            # Get F0 at multiple points
            f0_start = Get value at time: startpoint, "Hertz", "Linear"
            if f0_start = undefined
              f0_start = 0
            endif
            
            f0_end = Get value at time: endpoint, "Hertz", "Linear"
            if f0_end = undefined
              f0_end = 0
            endif
            
            # Get F0 statistics across the vowel
            selectObject: pitch
            f0_mean = Get mean: startTime, endTime, "Hertz"
            if f0_mean = undefined
              f0_mean = 0
            endif
            
            f0_sd = Get standard deviation: startTime, endTime, "Hertz"
            if f0_sd = undefined
              f0_sd = 0
            endif
            
            # Fix: Added "Parabolic" interpolation method
            f0_min = Get minimum: startTime, endTime, "Hertz", "Parabolic"
            if f0_min = undefined
              f0_min = 0
            endif
            
            # Fix: Added "Parabolic" interpolation method
            f0_max = Get maximum: startTime, endTime, "Hertz", "Parabolic"
            if f0_max = undefined
              f0_max = 0
            endif
          endif
          
          # Get formants
          selectObject: formant
          f1_mid = Get value at time: 1, midpoint, "Hertz", "Linear"
          if f1_mid = undefined
            f1_mid = 0
          endif
          
          f2_mid = Get value at time: 2, midpoint, "Hertz", "Linear"
          if f2_mid = undefined
            f2_mid = 0
          endif
          
          f3_mid = Get value at time: 3, midpoint, "Hertz", "Linear"
          if f3_mid = undefined
            f3_mid = 0
          endif
          
          if multiple_measurement_points
            # Get formants at multiple points
            f1_start = Get value at time: 1, startpoint, "Hertz", "Linear"
            if f1_start = undefined
              f1_start = 0
            endif
            
            f1_end = Get value at time: 1, endpoint, "Hertz", "Linear"
            if f1_end = undefined
              f1_end = 0
            endif
            
            f2_start = Get value at time: 2, startpoint, "Hertz", "Linear"
            if f2_start = undefined
              f2_start = 0
            endif
            
            f2_end = Get value at time: 2, endpoint, "Hertz", "Linear"
            if f2_end = undefined
              f2_end = 0
            endif
          endif
          
          # Get intensity
          selectObject: intensity
          intensity_mid = Get value at time: midpoint, "Cubic"
          if intensity_mid = undefined
            intensity_mid = 0
          endif
          
          if multiple_measurement_points
            # Get intensity statistics
            selectObject: intensity
            intensity_max = Get maximum: startTime, endTime, "Cubic"
            if intensity_max = undefined
              intensity_max = 0
            endif
            
            # Fix: Removed "Cubic" parameter as it's not valid for Get mean
            intensity_mean = Get mean: startTime, endTime
            if intensity_mean = undefined
              intensity_mean = 0
            endif
          endif
          
          # Initialize spectral measures with default values
          cog = 0
          sd_spectrum = 0
          skewness = 0
          kurtosis = 0
          
          # Only attempt to get spectral measures - removing voice quality measures
          if include_spectral_measures and multiple_measurement_points and duration > 0.05
            # Extract vowel segment for spectral measures
            selectObject: sound
            Extract part: startTime, endTime, "rectangular", 1, "no"
            vowel_sound = selected("Sound")
            
            # Get spectral moments
            To Spectrum: "yes"
            spectrum = selected("Spectrum")
            
            # Safely get spectral moments
            cog = Get centre of gravity: 2
            if cog = undefined
              cog = 0
            endif
            
            sd_spectrum = Get standard deviation: 2
            if sd_spectrum = undefined
              sd_spectrum = 0
            endif
            
            skewness = Get skewness: 2
            if skewness = undefined
              skewness = 0
            endif
            
            kurtosis = Get kurtosis: 2
            if kurtosis = undefined
              kurtosis = 0
            endif
            
            # Clean up temporary objects
            selectObject: vowel_sound, spectrum
            Remove
          endif
          
          # Write measurements to file - UPDATED OUTPUT (removed stress, syllable_position, word_position)
          if multiple_measurement_points and include_spectral_measures
            appendFileLine: output_file$, textgrid_file$, ",", speaker$, ",", persona$, ",", word_label$, ",", label$, ",", 
            ...startTime, ",", endTime, ",", duration, ",", preceding_phone$, ",", following_phone$, ",", 
            ...f0_start, ",", f0_mid, ",", f0_end, ",", f0_min, ",", f0_max, ",", f0_mean, ",", f0_sd, ",", 
            ...f1_start, ",", f1_mid, ",", f1_end, ",", 
            ...f2_start, ",", f2_mid, ",", f2_end, ",", 
            ...f3_mid, ",", 
            ...intensity_max, ",", intensity_mean, ",", 
            ...cog, ",", sd_spectrum, ",", skewness, ",", kurtosis
          elsif multiple_measurement_points
            appendFileLine: output_file$, textgrid_file$, ",", speaker$, ",", persona$, ",", word_label$, ",", label$, ",", 
            ...startTime, ",", endTime, ",", duration, ",", preceding_phone$, ",", following_phone$, ",", 
            ...f0_start, ",", f0_mid, ",", f0_end, ",", f0_min, ",", f0_max, ",", f0_mean, ",", f0_sd, ",", 
            ...f1_start, ",", f1_mid, ",", f1_end, ",", 
            ...f2_start, ",", f2_mid, ",", f2_end, ",", 
            ...f3_mid, ",", 
            ...intensity_max, ",", intensity_mean
          else
            appendFileLine: output_file$, textgrid_file$, ",", speaker$, ",", persona$, ",", word_label$, ",", label$, ",", 
            ...startTime, ",", endTime, ",", duration, ",", preceding_phone$, ",", following_phone$, ",", 
            ...f0_mid, ",", f1_mid, ",", f2_mid, ",", f3_mid, ",", intensity_mid
          endif
        endif
      endif
    endfor
    
    # Clean up objects for this file
    selectObject: sound, textgrid, pitch, formant, intensity
    Remove
    
    writeInfoLine: "Processed file ", fileIndex, " of ", numberOfFiles, ": ", textgrid_file$
  else
    writeInfoLine: "ERROR: Sound file not found for ", textgrid_file$
  endif
endfor

# Clean up file list
selectObject: "Strings textgrid_list"
Remove

writeInfoLine: "All measurements saved to: ", output_file$
writeInfoLine: "Total files processed: ", numberOfFiles