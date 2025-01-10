const fs = require('fs');

// Function to print the structure of an object
function printStructure(obj, level = 0, maxLevel = 2) {
  if (level > maxLevel || typeof obj !== 'object' || obj === null) {
    return;
  }

  const indent = '  '.repeat(level);

  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      console.log(`${indent}${key}`);

      if (typeof obj[key] === 'object' && obj[key] !== null) {
        printStructure(obj[key], level + 1, maxLevel);
      }
    }
  }
}

// Function to list all lua_classes, count rows, and print the structure of row 1
function processLuaPersistentData(data) {
  if (!Array.isArray(data)) {
    console.error('Invalid data structure: Expected an array.');
    return;
  }

  data.forEach((item, index) => {
    if (item.lua_class && item.table && Array.isArray(item.table)) {
      const rowCount = item.table.length;
      console.log(`\nLua Class: ${item.lua_class} table: ${index}`);
      console.log(`Number of rows: ${rowCount}`);

      // Show the structure of row 1 (index 0)
      if (rowCount > 0) {
        console.log(`Structure of row 1:`);
        printStructure(item.table[0], 0, 2);
      } else {
        console.log('No rows in this table.');
      }
    } else {
      console.log(`Skipping invalid or incomplete entry at index ${index}`);
    }
  });
}

// Load and parse the JSON file
const filePath = process.argv[2];
if (!filePath) {
  console.error('Please provide a JSON file path as an argument.');
  process.exit(1);
}

fs.readFile(filePath, 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading the file:', err);
    process.exit(1);
  }

  try {
    const jsonObject = JSON.parse(data);
    console.log('Processing Lua Persistent Data:');
    processLuaPersistentData(jsonObject.lua_persistent_json);
  } catch (err) {
    console.error('Invalid JSON format:', err);
  }
});
