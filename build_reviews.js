const fs=require('fs');
const path=require('path');
const dir=path.join(__dirname,'reviews');
const files=fs.readdirSync(dir).filter(f=>f.endsWith('.md'));
const reviews=[];
let id=1;
for(const file of files){
const text=fs.readFileSync(path.join(dir,file),'utf-8');
const lines=text.split('\n');
const data={};
for(const line of lines){
if(line.trim()===''||line.startsWith('---'))break;
const idx=line.indexOf(':');
if(idx===-1)continue;
const key=line.slice(0,idx).trim();
const value=line.slice(idx+1).trim();
data[key]=value;
}
const dateMatch=file.match(/^(\d{4}-\d{2}-\d{2})_/);
if(dateMatch)data.date=data.date||dateMatch[1];
if(data.rating)data.rating=parseFloat(data.rating);
data.id=id++;
reviews.push(data);
}
fs.writeFileSync(path.join(__dirname,'reviews.js'),`window.REVIEWS = ${JSON.stringify(reviews, null, 2)};`); 