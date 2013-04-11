
function emptyDiv(divId){
    div = $(divId);
	div.hide();
    div.html("");
	div.show("");
}


function addImage(divHandler, allImages, max_per_block, start_id){
    emptyDiv(divHandler);

	old_max_per_block = max_per_block;
    for(var row = 0;row < 1;row++){ 
		var images = allImages;
		var image_block = $('<div class="image_block">');

		image_block.css('display', 'inline-block').css('margin', '2px');

		var line = document.createElement("div");
		if (images[0]) {
			line.innerHTML = '<b>Tags: </b>' + images[0].tags;
		}
		image_block.append(line);

		var line = document.createElement("div");
		line.innerHTML = '<b>Iconic Images Groups</b>';
		image_block.append(line);
		
		line = $('<div>');
		var current_line_cnt = 0;
		max_per_block = old_max_per_block;
		if(max_per_block == -1) {
			max_per_block = images.length;
		}		

		max_per_block = Math.min(images.length, max_per_block);
		var max_per_row = Math.round(Math.sqrt(max_per_block));
		var currentImageCount = 0;
		for(var i = 0;i < images.length && currentImageCount < max_per_block;i++){		
			var imageUrl = '';
			var img = $("<img>");
			if (!images[i]) {
				continue;
			}
			if (images[i].url) {
				imageUrl = images[i].url;
			}
			if (images[i].thumbnail) {
				imageUrl = images[i].thumbnail;
			}
			if (!imageUrl) {
				continue;
			}
			 img.attr('src', imageUrl);
			 img.attr('width', 50);
			 img.attr('height', 50);

			 var newlink = $('<a>');
			 newlink.attr('href', '#').attr('onclick', "window.open('" + imageUrl + "');");//alert(" + (start_id +  row + 1) + ");");
			
			 newlink.append(img);
			 line.append(newlink);
			 current_line_cnt ++;
			 if (current_line_cnt == max_per_row) {
				current_line_cnt = 0;
				$(image_block).append(line);
				line = $("<div>");
			 }
			 currentImageCount ++;
		}

		$(image_block).append($(line));
		$(divHandler).append($(image_block));
    }
}  

function getWrapedText(text, maxlength) {    
    var resultText = [""];
    var len = text.length;    
    if (maxlength >= len) {
        return text;
    }
    else {
		var accLength = 0;
        while (text.length > 0) {         
			var nextWord = text.indexOf(',');
			if (nextWord == -1) {nextWord = text.length;}
			else {nextWord = nextWord + 1;}
			var breakPoint = Math.min( nextWord, maxlength - 1);
			var strPiece = text.substring(0, breakPoint);				
			if (accLength + strPiece.length > maxlength) {
				resultText.push("<br>");
				accLength = 0;
			}
			resultText.push(strPiece);
			accLength = accLength + strPiece.length;
			text = text.substring(breakPoint, text.length);            
        }
		
    }
    return resultText.join("");
}

function getImageGroupHTML(allImages, max_per_block, start_id, extraGroupData, width){
	var tmp_block = $('<div>');
	addImageGroup(tmp_block, allImages, max_per_block, start_id, extraGroupData, width);
	return tmp_block.html();
}  

function addImageGroup(divHandler, allImages, max_per_block, start_id, extraGroupData, width){
	if (!width) {
		width = 30;
	}
    emptyDiv(divHandler);
	console.log('add image group');
	old_max_per_block = max_per_block;
	
    for(var row = 0;row < allImages.length;row++){ 
		var images = allImages[row];
		if (!images) {
			continue;
		}
		var image_block = $('<div class="image_block">');

		image_block.css('display', 'inline-block').css('margin', '2px');

		var line = document.createElement("div");

		if (!extraGroupData) {
			line.innerHTML = '<b>Iconic Images Groups</b>';
		} else {
			line.innerHTML = '<b>' + extraGroupData.title + '</b>';		
		}
		image_block.append(line);

		line = document.createElement("div");
		if (images && images[0]) {
//			line.innerHTML = '<b>Tags: </b>' + getWrapedText(images[0].tags, 10);
			lineText = generateTagDesc(images, ',');
			line.innerHTML = '<b>Tags: </b>' + getWrapedText(lineText, width);
		}
		image_block.append(line);
		
		line = $('<div>');
		var current_line_cnt = 0;
		max_per_block = old_max_per_block;
		if(max_per_block == -1) {
			max_per_block = images.length;
		}		
		
		max_per_block = Math.min(images.length, max_per_block);
		var max_per_row = Math.round(Math.sqrt(max_per_block));
		var currentImageCount = 0;
		for(var i = 0;i < images.length && currentImageCount < max_per_block;i++){		
			var imageUrl = '';
			var img = $("<img>");
			if (!images[i]) {
				continue;
			}
			if (images[i].url) {
				imageUrl = images[i].url;
			}
			if (images[i].thumbnail) {
				imageUrl = images[i].thumbnail;
			}
			if (!imageUrl) {
				continue;
			}
			 img.attr('src', imageUrl);
			 img.attr('width', 50);
			 img.attr('height', 50);

			 var newlink = $('<a>');
			 newlink.attr('href', '#').attr('onclick', "window.open('" + imageUrl + "');");//alert(" + (start_id +  row + 1) + ");");
			
			 newlink.append(img);
			 line.append(newlink);
			 current_line_cnt ++;
			 if (current_line_cnt == max_per_row) {
				current_line_cnt = 0;
				$(image_block).append(line);
				line = $("<div>");
			 }
			 currentImageCount ++;
		}

		$(image_block).append($(line));
		$(divHandler).append($(image_block));
    }
}  


function getImageListsHTML(allImages, max_per_block, start_id, extraGroupData, width){
	var tmp_block = $('<div>');
	addImageLists(tmp_block, allImages, max_per_block, start_id, extraGroupData, width);
	return tmp_block.html();
}  

function addImageLists(divHandler, allImages, max_per_block, start_id, extraGroupData, width){
	if (!width) {
		width = 30;
	}
    emptyDiv(divHandler);

	console.log('add image group');
	old_max_per_block = max_per_block;
    for(var row = 0;row < allImages.length;row++){ 
		var images = allImages[row];
		if (!images) {
			continue;
		}
		var image_block = $('<div class="image_block_1">');
		
		var randNum =  parseInt(Math.random() * 10);
		console.log(randNum);
		if (row % randNum == 0) {
			image_block.css('display', 'inline-block').css('margin', '2px');
		}
		
		var line = document.createElement("div");

		if (!extraGroupData) {
			line.innerHTML = '<b>Iconic Images Groups</b>';
		} else {
			line.innerHTML = '<b>' + extraGroupData.title + '</b>';		
		}
		image_block.append(line);

		line = document.createElement("div");
		if (images && images[0]) {
			lineText = generateTagDesc(images, ',');
			line.innerHTML = '<b>Tags: </b>' + getWrapedText(lineText, width);
		}
		image_block.append(line);
		
		line = $('<div>');
		var current_line_cnt = 0;
		max_per_block = old_max_per_block;
		if(max_per_block == -1) {
			max_per_block = images.length;
		}		

		max_per_block = Math.min(images.length, max_per_block);
		var max_per_row = Math.round(Math.sqrt(max_per_block));
		var currentImageCount = 0;
		for(var i = 0;i < images.length && currentImageCount < max_per_block;i++){		
			var imageUrl = '';
			var img = $("<img>");
			if (!images[i]) {
				continue;
			}
			if (images[i].url) {
				imageUrl = images[i].url;
			}
			if (images[i].thumbnail) {
				imageUrl = images[i].thumbnail;
			}
			if (!imageUrl) {
				continue;
			}
			 img.attr('src', imageUrl);
			 img.attr('width', 50);
			 img.attr('height', 50);

			 var newlink = $('<a>');
			 newlink.attr('href', '#').attr('onclick', "window.open('" + imageUrl + "');");//alert(" + (start_id +  row + 1) + ");");
			
			 newlink.append(img);
			 line.append(newlink);
			 current_line_cnt ++;
			 if (current_line_cnt == max_per_row) {
				current_line_cnt = 0;
				$(image_block).append(line);
				line = $("<div>");
			 }
			 currentImageCount ++;
		}

		$(image_block).append($(line));
		$(divHandler).append($(image_block));
    }
}  

function getSortedTuple(hashmap) {
	var tuples = [];

	for (var key in hashmap) tuples.push([key, hashmap[key]]);

	tuples.sort(function(a, b) {
		a = a[1];
		b = b[1];
		return a < b ? 1 : (a > b ? -1 : 0);
	});
	return tuples;
}


function generateTagDesc(images, sep) {
	if (!sep) {
		sep = '<br>';
	}
	var tags_info = generateTagHist(images);
	var str = "";
	var tag_max = Math.min(10, tags_info.length);
	for(var i = 0;i<tag_max;i++){
		if(i==0){
			str = tags_info[i];
		}else{
			str = str + sep + tags_info[i];
		}
	}
	return str;
}
function generateTagHist(images) {
	hist = {};
	ret = [];
	for (var i = 0; i < images.length; ++i) {
		if (!images[i]) {
			continue;
		}
		var tags = images[i].tags;
		if (tags == undefined) {
			continue;
		}
		tags = tags.split(',');
		for (var j = 0; j < tags.length; ++j) {
			count = hist[tags[j]];
			if(count == undefined) {
				hist[tags[j]] = 1;
			} else {
				hist[tags[j]] = count + 1;			
			}
		}		
	}
	hist = getSortedTuple(hist);
	for (var i = 0; i < hist.length; ++i) {
		ret.push(hist[i][0] + ":" + hist[i][1]);
	}
	
	return ret;
}
