const URL = "<GOOGLE SHEETS URL HERE>";

// GET
function doGet(e) {
  sheetTableName = "Films";

  // Checking if dev mode activated
  if (e.parameter != null && e.parameter.devMode != null && e.parameter.devMode == 1) {
    // TRUE Giving dev testing table
    sheetTableName = "Films_dev";
  }

  var sheetURL = SpreadsheetApp.openByUrl(URL);
  var sheet = sheetURL.getSheetByName(sheetTableName);

  if (sheet.getLastRow() < 2) {
    // Returning empty if there is no films
    var output = "";
    return ContentService.createTextOutput(output).setMimeType(ContentService.MimeType.JSON);
  }

  var rows = sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn()).getValues();
  var outputData = [];

  for (var i = 0; rows.length > i; i++) {
    // setting up variables
    var row = rows[i], record = {};

    // writing values
    record['filmID'] = row[0];
    record['filmTitle'] = row[1];

    // Convert row[2] to a string and then split it
    record['filmGenresIDs'] = String(row[2]).split(',');

    record['filmIsWatched'] = row[3];

    outputData.push(record);
  }

  // Converting array to text
  var output = JSON.stringify(outputData);

  // Returning values as JSON
  return ContentService.createTextOutput(output).setMimeType(ContentService.MimeType.JSON);
}

// POST
function doPost(e) {
  if (e.postData.type !== "application/json") {
    return ContentService.createTextOutput("Unexpected post type! Should be JSON!").setMimeType(ContentService.MimeType.TEXT);
  }

  // Parsing json
  var json = JSON.parse(e.postData.contents);
  var devMode = json.devMode? json.devMode == 1 : false;

  // "https://docs.google.com/spreadsheets/d/1osZ46Z1Sn9nuhmII5HszrlBB6nx3an7jn2niGZOJBtQ/edit?pli=1#gid=0"
  var sheetURL = SpreadsheetApp.openByUrl(URL);
  var sheetTableName = devMode ? "Films_dev" : "Films";
  var sheet = sheetURL.getSheetByName(sheetTableName);

  // To avoid problem when id gets title which is at position 1
  var newID = sheet.getLastRow() > 1 ? sheet.getRange(sheet.getLastRow(), 1).getValue() + 1 : 0;

  // Access JSON data
  var apiAction = json.apiAction;

  // Creating new ID if adding a new Film
  // Otherwise using ID in json
  var filmID = apiAction == "ADD" ? newID : json.filmID;
  var filmTitle = "'" + json.filmTitle;
  var filmGenresIDsRaw = json.filmGenresIDs;
  var filmIsWatched = apiAction == "ADD"? "0" : json.filmIsWatched; // Same thing as ID

  // Adding ` before genres to avoid converting for example "1,3,5" to DATE
  var filmGenresIDs = filmGenresIDsRaw.length > 0 ? "'" + filmGenresIDsRaw.join(",") : "";

  // Combining all vars to one object for easier use
  var film = [filmID, filmTitle, filmGenresIDs, filmIsWatched];

  if (apiAction == "ADD"){
    // Writing the data to the sheet

    var filmExists = checkIfFilmAlreadyExists(film, sheet);

    if (filmExists) {
      return ContentService.createTextOutput("EXISTS").setMimeType(ContentService.MimeType.TEXT);
    }

    sheet.appendRow(film);
    return ContentService.createTextOutput("SUCCESS").setMimeType(ContentService.MimeType.TEXT);
  }
  if (apiAction == "EDIT") {
    return doEdit(film, sheet);
  }
  if (apiAction == "DELETE") {
    return doDelete(film, sheet);
  }

  // Return a error
  return ContentService.createTextOutput("Unable to process data!").setMimeType(ContentService.MimeType.TEXT);
}

function doDelete(film, sheet) {
  var neededRow = findRow(film[0], sheet);

  if (neededRow > 0){
    sheet.deleteRow(neededRow);

    return ContentService.createTextOutput("DELETED").setMimeType(ContentService.MimeType.TEXT);
  }

  return ContentService.createTextOutput("NOT_FOUND").setMimeType(ContentService.MimeType.TEXT);
}

function doEdit(film, sheet) {
  // Replacing a film and getting result DOESNT WORK WELL
  // var result = replaceFilmInSheet(film[0], film, sheet)

  var neededRow = findRow(film[0], sheet);

  if (neededRow > 0){
    sheet.deleteRow(neededRow);
    sheet.appendRow(film);

    return ContentService.createTextOutput("SUCCESS").setMimeType(ContentService.MimeType.TEXT);
  }

  return ContentService.createTextOutput("NOT_FOUND").setMimeType(ContentService.MimeType.TEXT);
}

function replaceFilmInSheet(filmID, newFilmData, sheet) {
  // Get all the data from the sheet
  var data = sheet.getDataRange().getValues();
  // Find the row to replace based on a unique identifier (e.g., ID in the first column)
  for (var i = 0; i < data.length; i++) {
    if (data[i][0] == filmID) { // Assuming the ID is in the first column
      // Replace the entire row with the new data
      data[i] = newFilmData;
      break; // Stop searching once the row is found and replaced
    }

    if (i == data.length - 1) {
      // If not found no need to replace anything
      return false;
    }
  }

  // Clear the existing data in the sheet
  sheet.clearContents();

  // Write the modified data back to the sheet
  sheet.getRange(1, 1, data.length, data[0].length).setValues(data);

  return true;
}

function findRow(index, sheet) {
  var rows = sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn()).getValues();

  for (var i = 0; rows.length > i; i++) {
    // setting up variables
    var row = rows[i];

    if (row[0] == index){
      return i + 2;
    }
  }

  return 0;
}

function checkIfFilmAlreadyExists(film, sheet) {
  // Get all the data from the sheet
  var data = sheet.getDataRange().getValues();

  for (var i = 0; i < data.length; i++) {
    if (data[i][1] == film[1]) { // Assuming the title is in the second column
      // returning
      return true
    }
  }

  return false;
}
