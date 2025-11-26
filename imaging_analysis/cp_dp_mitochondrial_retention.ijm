// CP and dP Analysis with T20 Mask
// Returns: Total CP/dP spots before T20 mask and CP/dP spots within T20 mask

macro "CP and dP Analysis with T20 Mask" {
    
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
    
    // Close C4 if present
    if (isOpen("C4-" + roi_title)) {
        selectWindow("C4-" + roi_title);
        close();
    }
    
    // Step 3: Process CP channel
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
    
    // Step 4: Process dP channel
    selectWindow("dP_original");
    run("Duplicate...", "title=dP_processed");
    selectWindow("dP_processed");
    run("Grays");
    run("Subtract Background...", "rolling=50");
    run("Gaussian Blur...", "sigma=2");
    run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 24 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");
    run("Minimum...", "radius=2");
    run("Gaussian Blur...", "sigma=2");
    
    // Step 5: Process T20 channel
    selectWindow("T20_original");
    run("Duplicate...", "title=T20_processed");
    selectWindow("T20_processed");
    run("Green");
    run("Subtract Background...", "rolling=50");
    run("Enhance Contrast", "saturated=0.35");
    run("Gaussian Blur...", "sigma=2");
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT");
    
    // ===== COUNT TOTAL SPOTS BEFORE T20 MASK =====
    print("=== SPOT COUNTING BEFORE T20 MASK ===");
    
    // Count total CP spots (before mask)
    run("Clear Results");
    selectWindow("CP_processed");
    run("Find Maxima...", "prominence=15 output=[Point Selection]");
    
    cp_spots_total = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints, ypoints);
        cp_spots_total = xpoints.length;
    }
    print("Total CP spots (before T20 mask): " + cp_spots_total);
    
    // Create visualization
    selectWindow("CP_processed");
    run("Find Maxima...", "prominence=15 output=[Maxima Within Tolerance]");
    rename("CP_spots_total");
    saveAs("Tiff", output_dir + "CP_spots_total.tif");
    
    // Count total dP spots (before mask)
    run("Clear Results");
    selectWindow("dP_processed");
    run("Find Maxima...", "prominence=12 output=[Point Selection]");
    
    dp_spots_total = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints2, ypoints2);
        dp_spots_total = xpoints2.length;
    }
    print("Total dP spots (before T20 mask): " + dp_spots_total);
    
    // Create visualization
    selectWindow("dP_processed");
    run("Find Maxima...", "prominence=12 output=[Maxima Within Tolerance]");
    rename("dP_spots_total");
    saveAs("Tiff", output_dir + "dP_spots_total.tif");
    
    // ===== CREATE T20 MASK =====
    print("\n=== CREATING T20 MASK ===");
    selectWindow("T20_processed");
    run("Duplicate...", "title=T20_mask");
    selectWindow("T20_mask");
    run("Auto Threshold", "method=Otsu");
    run("Convert to Mask");
    saveAs("Tiff", output_dir + "T20_mask.tif");
    
    // ===== APPLY T20 MASK TO CP (KEEP INTENSITY VALUES) =====
    selectWindow("CP_processed");
    run("Duplicate...", "title=T20_mask_overlay_CP_for_spots");
    run("32-bit");
    selectWindow("T20_mask.tif");
    run("Duplicate...", "title=T20_mask_for_CP");
    run("32-bit");
    run("Divide...", "value=255"); // Normalize mask to 0-1 range
    imageCalculator("Multiply", "T20_mask_overlay_CP_for_spots", "T20_mask_for_CP");
    selectWindow("T20_mask_overlay_CP_for_spots");
    
    // Create a thresholded version for saving
    run("Duplicate...", "title=T20_mask_overlay_CP");
    run("Threshold...");   
    waitForUser("Adjust the Threshold for CP within T20 as needed and click OK");
    run("Convert to Mask");
    run("32-bit");
    saveAs("Tiff", output_dir + "T20_mask_overlay_CP.tif");
    
    // ===== APPLY T20 MASK TO dP (KEEP INTENSITY VALUES) =====
    selectWindow("dP_processed");
    run("Duplicate...", "title=T20_mask_overlay_dP_for_spots");
    run("32-bit");
    selectWindow("T20_mask.tif");
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
    
    // ===== COUNT SPOTS WITHIN T20 MASK =====
    print("\n=== SPOT COUNTING WITHIN T20 MASK ===");
    
    // Count CP spots within T20 mask using the intensity-preserved image
    run("Clear Results");
    selectWindow("T20_mask_overlay_CP_for_spots");
    run("Find Maxima...", "prominence=15 output=[Point Selection]");
    
    cp_spots_in_t20 = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints3, ypoints3);
        cp_spots_in_t20 = xpoints3.length;
    }
    print("CP spots within T20 mask: " + cp_spots_in_t20);
    
    // Create visualization
    selectWindow("T20_mask_overlay_CP_for_spots");
    run("Find Maxima...", "prominence=15 output=[Maxima Within Tolerance]");
    rename("CP_spots_in_T20");
    saveAs("Tiff", output_dir + "CP_spots_in_T20.tif");
    
    // Count dP spots within T20 mask using the intensity-preserved image
    run("Clear Results");
    selectWindow("T20_mask_overlay_dP_for_spots");
    run("Find Maxima...", "prominence=12 output=[Point Selection]");
    
    dp_spots_in_t20 = 0;
    if (selectionType() == 10) { // Point selection type
        getSelectionCoordinates(xpoints4, ypoints4);
        dp_spots_in_t20 = xpoints4.length;
    }
    print("dP spots within T20 mask: " + dp_spots_in_t20);
    
    // Create visualization
    selectWindow("T20_mask_overlay_dP_for_spots");
    run("Find Maxima...", "prominence=12 output=[Maxima Within Tolerance]");
    rename("dP_spots_in_T20");
    saveAs("Tiff", output_dir + "dP_spots_in_T20.tif");
    
    // ===== FINAL SUMMARY =====
    print("\n=== FINAL SUMMARY ===");
    print("1. Total CP spots (before T20 mask): " + cp_spots_total);
    print("2. Total dP spots (before T20 mask): " + dp_spots_total);
    print("3. CP spots within T20 mask: " + cp_spots_in_t20);
    print("4. dP spots within T20 mask: " + dp_spots_in_t20);
    print("\nSPOTS LOST TO T20 MASKING:");
    print("  CP spots lost: " + (cp_spots_total - cp_spots_in_t20));
    print("  dP spots lost: " + (dp_spots_total - dp_spots_in_t20));
    if (cp_spots_total > 0) {
        print("  CP retention: " + d2s((cp_spots_in_t20/cp_spots_total)*100, 1) + "%");
    }
    if (dp_spots_total > 0) {
        print("  dP retention: " + d2s((dp_spots_in_t20/dp_spots_total)*100, 1) + "%");
    }
    print("======================\n");
    
    print("Results saved to: " + output_dir);
    
    // Save results log
    selectWindow("Log");
    saveAs("Text", output_dir + "CP_dP_T20_Analysis_Results.txt");
    
    showMessage("Analysis Complete", 
        "1. Total CP spots: " + cp_spots_total + "\n" +
        "2. Total dP spots: " + dp_spots_total + "\n" +
        "3. CP within T20: " + cp_spots_in_t20 + "\n" +
        "4. dP within T20: " + dp_spots_in_t20 + "\n\n" +
        "Results saved to:\n" + output_dir);

    run("Close All");
}