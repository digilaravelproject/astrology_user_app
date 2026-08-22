const fs = require('fs');
const data = JSON.parse(fs.readFileSync('en_US.json', 'utf8'));

for (let key in data) {
  if (/[\u0900-\u097F]/.test(data[key])) {
    data[key] = key;
  }
}

fs.writeFileSync('en_US.json', JSON.stringify(data, null, 2) + '\n');
