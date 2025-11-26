// Mitochondrial Nucleoid Analysis Macro - Fixed Version
// Analyzes 4-channel images: CP (C1), dP (C2), T20 (C3), TFAM (C4)

macro "Mitochondrial Nucleoid Analysis Fixed" {
    
    // Step 1: Open image and select ROI
    open();
    original_title = getTitle();
    
    // Ask user to select ROI
    setTool("polygon");
    waitForUser("Please select your ROI and click OK when ready");
    
    // Check if ROI is selected
    if (selectionType() == -1) {
        exit("No ROI selected. Please run the macro again and select an ROI.");
    }
    
    // Get destination folder
    output_dir = getDirectory("Choose destination folder for results");
    
    // Clear outside ROI first, then crop
    run("Clear Outside");
    run("Select All");
    run("Crop");
    roi_title = "ROI_" + original_title;
    rename(roi_title);
    
    // Save ROI image
    saveAs("Tiff", output_dir + roi_title);
    
    // Step 2: Split channels and rename
    run("Split Channels");
    
    // Rename channels
    selectWindow("C1-" + roi_title);
    rename("CP_original");
    
    selectWindow("C2-" + roi_title);
    rename("dP_original");
    
    selectWindow("C3-" + roi_title);
    rename("T20_original");
    
    selectWindow("C4-" + roi_title);
    rename("TF_original");
    
    // Step 3: Process each channel (keeping originals for comparison)
    
    // Process CP channel
    selectWindow("CP_original");
    run("Duplicate...", "title=CP_processed");
    selectWindow("CP_processed");
    run("Green");
    run("Subtract Background...", "rolling=50");
    run("Gaussian Blur...", "sigma=2");
    run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 24 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");
    run("Minimum...", "radius=2");
    run("Gaussian Blur...", "sigma=2");
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT");
    
    // Process dP channel
    selectWindow("dP_original");
    run("Duplicate...", "title=dP_processed");
    selectWindow("dP_processed");
    run("Grays");
    run("Subtract Background...", "rolling=50");
    run("Gaussian Blur...", "sigma=2");
    run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 24 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");
    run("Minimum...", "radius=2");
    run("Gaussian Blur...", "sigma=2");
    
    // Process T20 channel
    selectWindow("T20_original");
    run("Duplicate...", "title=T20_processed");
    selectWindow("T20_processed");
    run("Green");
    run("Subtract Background...", "rolling=50");
    run("Enhance Contrast", "saturated=0.35");
    run("Gaussian Blur...", "sigma=2");
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT");
    
    // Process TF channel
    selectWindow("TF_original");
    run("Duplicate...", "title=TF_processed");
    selectWindow("TF_processed");
    run("Magenta");
    run("Subtract Background...", "rolling=20");
    run("Enhance Contrast", "saturated=0.35");
    run("Gaussian Blur...", "sigma=2");
    run("Subtract Background...", "rolling=20");
    run("Enhance Contrast", "saturated=0.35");
    resetMinAndMax();
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT");
    
    // Step 4: Create T20 mask and apply to CP and dP
    selectWindow("T20_processed");
    run("Duplicate...", "title=T20_mask");
    selectWindow("T20_mask");
    
    // Create binary mask from T20
    run("Auto Threshold", "method=Otsu");
    run("Convert to Mask");
    
    // Apply mask to CP - KEEP TWO VERSIONS: one for counting, one for visualization
    selectWindow("CP_processed");
    run("Duplicate...", "title=T20_mask_overlay_CP_for_counting");
    run("32-bit");
    selectWindow("T20_mask");
    run("Duplicate...", "title=T20_mask_for_CP");
    run("32-bit");
    run("Divide...", "value=255"); // Normalize mask to 0-1 range
    imageCalculator("Multiply", "T20_mask_overlay_CP_for_counting", "T20_mask_for_CP");
    
    // Create visualization version with thresholding
    selectWindow("T20_mask_overlay_CP_for_counting");
    run("Duplicate...", "title=T20_mask_overlay_CP");
    run("Threshold...");   
    waitForUser("Adjust the CP Threshold as needed and click OK");
    run("Convert to Mask");
    run("32-bit");
    saveAs("Tiff", output_dir + "T20_mask_overlay_CP.tif");
    
    // Apply mask to dP - KEEP TWO VERSIONS: one for counting, one for visualization
    selectWindow("dP_processed");
    run("Duplicate...", "title=T20_mask_overlay_dP_for_counting");
    run("32-bit");
    selectWindow("T20_mask");
    run("Duplicate...", "title=T20_mask_for_dP");
    run("32-bit");
    run("Divide...", "value=255");
    imageCalculator("Multiply", "T20_mask_overlay_dP_for_counting", "T20_mask_for_dP");
    
    // Create visualization version with thresholding
    selectWindow("T20_mask_overlay_dP_for_counting");
    run("Duplicate...", "title=T20_mask_overlay_dP");
    run("Threshold...");   
    waitForUser("Adjust the dP Threshold as needed and click OK");
    run("Convert to Mask");
    run("32-bit");
    saveAs("Tiff", output_dir + "T20_mask_overlay_dP.tif");
    
    // Step 7: Count spots with proper results table handling - COUNT ON INTENSITY-PRESERVED IMAGES
    print("=== SPOT COUNTING RESULTS ===");
    
    // Clear results table before starting
    run("Clear Results");
    
    // Count CP spots on the INTENSITY-PRESERVED image
    selectWindow("T20_mask_overlay_CP_for_counting");
    run("Find Maxima...", "prominence=15 output=[Point Selection]");
    
    cp_spots = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints, ypoints);
        cp_spots = xpoints.length;
    }
    print("CP Spots: " + cp_spots);
    
    // Show CP maxima for verification
    selectWindow("T20_mask_overlay_CP_for_counting");
    run("Find Maxima...", "prominence=15 output=[Maxima Within Tolerance]");
    rename("CP_spots_detected");
    saveAs("Tiff", output_dir + "CP_spots_detected.tif");
    
    // Clear results table before next measurement
    run("Clear Results");
    
    // Count dP spots on the INTENSITY-PRESERVED image
    selectWindow("T20_mask_overlay_dP_for_counting");
    run("Find Maxima...", "prominence=12 output=[Point Selection]");
    
    dp_spots = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints2, ypoints2);
        dp_spots = xpoints2.length;
    }
    print("dP Spots: " + dp_spots);
    
    // Show dP maxima for verification
    selectWindow("T20_mask_overlay_dP_for_counting");
    run("Find Maxima...", "prominence=12 output=[Maxima Within Tolerance]");
    rename("dP_spots_detected");
    saveAs("Tiff", output_dir + "dP_spots_detected.tif");
    
    // Step 8: Find co-localized spots (dP spots that are near CP spots)
    // Get CP spot coordinates
    run("Clear Results");
    selectWindow("T20_mask_overlay_CP_for_counting");
    run("Find Maxima...", "prominence=15 output=List");
    
    cp_x = newArray(nResults);
    cp_y = newArray(nResults);
    for (i = 0; i < nResults; i++) {
        cp_x[i] = getResult("X", i);
        cp_y[i] = getResult("Y", i);
    }
    
    // Get dP spot coordinates
    run("Clear Results");
    selectWindow("T20_mask_overlay_dP_for_counting");
    run("Find Maxima...", "prominence=12 output=List");
    
    dp_x = newArray(nResults);
    dp_y = newArray(nResults);
    for (i = 0; i < nResults; i++) {
        dp_x[i] = getResult("X", i);
        dp_y[i] = getResult("Y", i);
    }
    
    // Find dP spots that are within distance threshold of any CP spot
    distance_threshold = 3; // pixels - adjust if needed
    total_spots = 0;
    
    for (i = 0; i < dp_x.length; i++) {
        is_colocalized = false;
        for (j = 0; j < cp_x.length; j++) {
            distance = sqrt(pow(dp_x[i] - cp_x[j], 2) + pow(dp_y[i] - cp_y[j], 2));
            if (distance <= distance_threshold) {
                is_colocalized = true;
                break;
            }
        }
        if (is_colocalized) {
            total_spots++;
        }
    }
    
    print("CP+dP spots (co-localized dP): " + total_spots);
    print("(dP spots within " + distance_threshold + " pixels of a CP spot)");
    
    // Step 9: Calculate normalized values
    print("=== NORMALIZATION RESULTS ===");
    if (cp_spots > 0) {
        spots_norm_to_cp = total_spots / cp_spots;
        print("Spots normalized to CP: " + spots_norm_to_cp);
    } else {
        print("Spots normalized to CP: Cannot calculate (CP spots = 0)");
    }
    
    if (dp_spots > 0) {
        spots_norm_to_dp = total_spots / dp_spots;
        print("Spots normalized to dP: " + spots_norm_to_dp);
    } else {
        print("Spots normalized to dP: Cannot calculate (dP spots = 0)");
    }
    
    // Calculate deletion percentage (dP spots relative to CP spots)
    if (cp_spots > 0) {
        cp_spot_alone_percentage = ((cp_spots - total_spots)/cp_spots) * 100;
        print("percentage of CP spots alone: " + cp_spot_alone_percentage + "%");
    }
    
    print("=== ANALYSIS COMPLETE ===");
    print("Results saved to: " + output_dir);
    
    // Save results log
    selectWindow("Log");
    saveAs("Text", output_dir + "Analysis_Results.txt");
    
    showMessage("Analysis Complete", "All processing steps completed successfully!\nCheck the Log window for detailed results.\nResults saved to: " + output_dir);

    run("Close All");
}