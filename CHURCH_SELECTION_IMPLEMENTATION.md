# Church Selection in Leaderboard - Implementation Summary

## Overview
Implemented church selection functionality in the leaderboard screen (CollectionDetailsScreen) with automatic saving to "final" documents in existing collections.

## Features Implemented

### 1. Church Selection in Leaderboard
- **Selection Mode Toggle**: Added checkbox icon in app bar to enter selection mode
- **Visual Feedback**: Selected churches are highlighted with orange background and border
- **Checkbox Interface**: Each church row shows a checkbox when in selection mode
- **Selection Count**: App bar shows count of selected churches when in selection mode

### 2. Selected Churches Display Screen
- **Clean Display**: Shows only church names in a simple list format
- **No Specific Order**: Churches are displayed in selection order, not ranked
- **Professional Layout**: Clean white cards with green accent colors
- **Action Buttons**: Save functionality accessible via app bar and bottom button

### 3. Automatic Firestore Saving
- **Collection Structure**: Saves to existing collections (kg1Results, kg2Results, etc.)
- **Document Name**: Creates/updates document named "final" in each collection
- **Data Format**: Stores churches in an array called "churches" containing only church names
- **Merge Strategy**: Uses SetOptions(merge: true) to preserve existing data

### 4. Gallery Save Functionality
- **Screenshot Capture**: Uses screenshot package to capture the certificate design
- **Permission Handling**: Requests storage permission before saving
- **Professional Design**: Beautiful certificate-style layout with logos, level name, and church list
- **File Naming**: Saves with descriptive Arabic names including level and timestamp
- **Gallery Organization**: Saves to "Pictures/تحكيم الأحان" folder for easy organization

## Technical Details

### Collections Supported
All 16 competition categories:
- kg1Results, kg2Results, kgGResults, kgFResults
- oulaTanya1Results, oulaTanya2Results, oulaTanyaGResults, oulaTanyaFResults  
- taltaRaba1Results, taltaRaba2Results, taltaRabaGResults, taltaRabaFResults
- khamsaSadsa1Results, khamsaSadsa2Results, khamsaSadsaGResults, khamsaSadsaFResults

### Document Structure for "final" Documents
```json
{
  "day": "final",
  "churches": ["Church Name 1", "Church Name 2", ...],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Navigation Flow
1. User opens leaderboard (CollectionDetailsScreen)
2. Taps checkbox icon to enter selection mode
3. Selects desired churches using checkboxes
4. Taps done icon to proceed to display screen
5. Reviews selected churches in SelectedChurchesDisplayScreen
6. Taps save to store in Firestore and gallery

## UI/UX Features
- **RTL Arabic Support**: All text properly displayed in Arabic
- **Responsive Design**: Works on different screen sizes
- **Visual Hierarchy**: Clear distinction between selected/unselected states
- **Loading States**: Shows progress indicators during save operations
- **Error Handling**: Displays error messages if save fails
- **Success Feedback**: Shows confirmation when save completes

## Files Modified
- `lib/screens/check_status_screen.dart`: Enhanced CollectionDetailsScreen with selection functionality and added SelectedChurchesDisplayScreen

## Dependencies Used
- `cloud_firestore`: For database operations
- `saver_gallery`: For saving images to device gallery
- `screenshot`: For capturing screenshot of the certificate design
- `permission_handler`: For requesting gallery permissions

## Certificate Design Features
- **Header Layout**: Two logo placeholders in corners with centered title
- **Level Display**: Prominent display of the competition level name
- **Professional Styling**: Clean white background with green accents and shadows
- **Church List**: Numbered list with individual cards for each church
- **Footer**: Timestamp showing when the certificate was created
- **Responsive Design**: Scales properly for different screen sizes

## Gallery Save Process
1. Requests storage permission from user
2. Captures screenshot of the certificate design
3. Saves to device gallery with Arabic filename
4. Organizes in dedicated "تحكيم الأحان" folder
5. Provides success/error feedback to user
