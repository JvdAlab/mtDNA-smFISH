// Mitochondrial Nucleoid Analysis Macro - dP Channel Version
// Analyzes 4-channel images: CP (C1), dP (C2), T20 (C3), TFAM (C4)

macro "Mitochondrial Nucleoid Analysis dP Final Fixed" {
    
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
    
    // Step 3: Process each channel
    
    // Process dP channel (using the exact processing from your first code)
    selectWindow("dP_original");
    run("Duplicate...", "title=dP_processed");
    selectWindow("dP_processed");
    run("Grays");
    // Note: dP processing from your original code
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
    run("Apply LUT");
    
    // Step 4: Create T20 mask and apply to dP
    selectWindow("T20_processed");
    run("Duplicate...", "title=T20_mask");
    selectWindow("T20_mask");
    
    // Create binary mask from T20
    run("Auto Threshold", "method=Otsu");
    run("Convert to Mask");
    
    // Apply mask to dP - KEEP INTENSITY VALUES FOR SPOT DETECTION
    selectWindow("dP_processed");
    run("Duplicate...", "title=T20_mask_overlay_dP_for_spots");
    run("32-bit");
    selectWindow("T20_mask");
    run("Duplicate...", "title=T20_mask_for_dP");
    run("32-bit");
    run("Divide...", "value=255"); // Normalize mask to 0-1 range
    imageCalculator("Multiply", "T20_mask_overlay_dP_for_spots", "T20_mask_for_dP");
    selectWindow("T20_mask_overlay_dP_for_spots");
    
    // Create a thresholded version for saving
    run("Duplicate...", "title=T20_mask_overlay_dP");
    run("Threshold...");   
    waitForUser("Adjust the Threshold for dP within T20 as needed and click OK");
    run("Convert to Mask");
    run("32-bit");
    saveAs("Tiff", output_dir + "T20_mask_overlay_dP.tif");
    
    // Create TF mask
    selectWindow("TF_processed");
    run("Duplicate...", "title=TF_mask");
    selectWindow("TF_mask");
    
    // Create binary mask from TF
    run("Auto Threshold", "method=Otsu");
    run("Convert to Mask");
    
    // Apply TF mask to the intensity-preserved dP image
    selectWindow("T20_mask_overlay_dP_for_spots");
    run("Duplicate...", "title=TF_T20_mask_overlay_dP_for_spots");
    run("32-bit");
    selectWindow("TF_mask");
    run("Duplicate...", "title=TF_mask_for_overlay");
    run("32-bit");
    run("Divide...", "value=255");
    imageCalculator("Multiply", "TF_T20_mask_overlay_dP_for_spots", "TF_mask_for_overlay");
    selectWindow("TF_T20_mask_overlay_dP_for_spots");
    
    // Create a version for saving
    run("Duplicate...", "title=TF_T20_mask_overlay_dP");
    run("32-bit");
    saveAs("Tiff", output_dir + "TF_T20_mask_overlay_dP.tif");
    
    // SPOT COUNTING ON INTENSITY-PRESERVED IMAGES
    print("=== SPOT COUNTING RESULTS ===");
    
    // Count dP spots within T20 mask using the intensity-preserved image
    run("Clear Results");
    selectWindow("T20_mask_overlay_dP_for_spots");
    run("Find Maxima...", "prominence=12 output=[Point Selection]");
    
    dp_spots_in_t20 = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints, ypoints);
        dp_spots_in_t20 = xpoints.length;
    }
    print("dP Spots within T20 mask: " + dp_spots_in_t20);
    
    // Create visualization
    selectWindow("T20_mask_overlay_dP_for_spots");
    run("Find Maxima...", "prominence=12 output=[Maxima Within Tolerance]");
    current_image = getTitle();
    if (indexOf(current_image, "Maxima") >= 0 || indexOf(current_image, "T20_mask_overlay_dP_for_spots") >= 0) {
        rename("dP_spots_in_T20_detected");
        saveAs("Tiff", output_dir + "dP_spots_in_T20_detected.tif");
    }
    
    // Count dP spots within both T20 and TF masks using the intensity-preserved image
    run("Clear Results");
    selectWindow("TF_T20_mask_overlay_dP_for_spots");
    run("Find Maxima...", "prominence=12 output=[Point Selection]");
    
    dp_spots_in_t20_tf = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints2, ypoints2);
        dp_spots_in_t20_tf = xpoints2.length;
    }
    print("dP Spots within both T20 and TF masks: " + dp_spots_in_t20_tf);
    
    // Create visualization
    selectWindow("TF_T20_mask_overlay_dP_for_spots");
    run("Find Maxima...", "prominence=12 output=[Maxima Within Tolerance]");
    current_image2 = getTitle();
    if (indexOf(current_image2, "Maxima") >= 0 || indexOf(current_image2, "TF_T20_mask_overlay_dP_for_spots") >= 0) {
        rename("dP_spots_in_T20_TF_detected");
        saveAs("Tiff", output_dir + "dP_spots_in_T20_TF_detected.tif");
    }
    
    // Calculate percentage
    if (dp_spots_in_t20 > 0) {
        dp_in_tf_percentage = (dp_spots_in_t20_tf / dp_spots_in_t20) * 100;
        print("Percentage of dP spots (within T20) that are also within TF mask: " + dp_in_tf_percentage + "%");
    } else {
        print("Cannot calculate percentage (no dP spots within T20 mask)");
    }
    
    print("=== ANALYSIS COMPLETE ===");
    print("Results saved to: " + output_dir);
    
    // Save results log
    selectWindow("Log");
    saveAs("Text", output_dir + "Analysis_Results.txt");
    
    showMessage("Analysis Complete", "All processing steps completed successfully!\nCheck the Log window for detailed results.\nResults saved to: " + output_dir);

    run("Close All");
}