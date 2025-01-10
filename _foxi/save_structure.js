

const fs = require('fs');

// Function to print the structure of a JSON object up to 3 levels
function printStructure(obj, level = 0, maxLevel = 3) {
  if (level > maxLevel || typeof obj !== 'object' || obj === null) {
    return;
  }

  const indent = '  '.repeat(level);

  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      console.log(`${indent}${key}`);

      // If the value is an object or array, recursively print its structure
      if (typeof obj[key] === 'object' && obj[key] !== null) {
        printStructure(obj[key], level + 1, maxLevel);
      }
    }
  }
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
    console.log('JSON structure (up to 3 levels):');
    printStructure(jsonObject);
  } catch (err) {
    console.error('Invalid JSON format:', err);
  }
});
