var fs = require('fs');
var poFile = fs.readFileSync("th_ID.po", 'utf-8');
var linesInPoFile = poFile.split('\n');
var curState = {
	itemStart: false,
	msgid: null,
	msgstr: null,
}
var isNotHead = false;
// var csvStr = "中文,	印尼文" + "\n";
// var csvs = [{a:"中文", b:"印尼文"}];
var csvs = [["中文", "印尼文"]];
for(var i = 0; i < linesInPoFile.length; i++){
	var lineStr = linesInPoFile[i]
	if (curState.itemStart){
		if(lineStr.match(/^msgstr.+/)){
			curState.msgstr = lineStr.match(/^msgstr \"(.*)\"/)[1];
		}
		else if(lineStr.match(/^\"(.*)\"/)){
			if(curState.msgstr != null){
				curState.msgstr = curState.msgstr + lineStr.match(/^\"(.*)\"/)[1];
			}else{
				curState.msgid = curState.msgid + lineStr.match(/^\"(.*)\"/)[1];
				// console.log(curState.msgid);
			}
		}
		else if(curState.msgstr != null) {
			var msgid = curState.msgid;
			var msgstr = curState.msgstr;
			if(curState.msgstr == "" || curState.msgstr == curState.msgid){
				csvs.push([msgid, msgstr]);
				// csvs.push({a:msgid, b:msgstr});
				// csvStr = csvStr + msgid + ",	" + msgstr + "\n";
			}
			curState.itemStart = false;
			curState.msgid = null;
			curState.msgstr = null;
		}
	}else if(isNotHead && lineStr.match(/^msgid.+/)){
		curState.itemStart = true;
		curState.msgid = lineStr.match(/^msgid \"(.*)\"/)[1];
	}else if(!isNotHead){
		if(lineStr.match(/^#/)){
			isNotHead = true
		}
	}else{
	}
}

var csv = require('csv');
// console.log(csv);
// var data = [ 
//     ['john', 23, '城市'],
//     ['john2', 123, 'male'],
//     ['john3', 234, 'female']
// ];
var fout=fs.createWriteStream('untranslated.csv');
fout.write(new Buffer('\xEF\xBB\xBF','binary'));//add utf-8 bom
// csv().from.array(csvs).to(fout);
csv.stringify(csvs)
  .pipe(fout);

// fs.writeFile("untranslated.txt", csvStr, 'utf8', function(err) {
//     if(err) {
//         return console.log(err);
//     }
//     console.log("untranslated was saved!");
// }); 