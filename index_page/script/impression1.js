
function emptyDiv(divId){
    div = $(divId);
	div.hide();
    div.html("");
	div.show("");
}

// Prerequisite:
//	1. An empty hidden division with class image_preview
function preview(event, json) {
	var image = eval(json);
	emptyDiv($('.image_preview'));
	var block = $('<div class="image_block">');
	var image_url = image.url_m ? image.url_m: image.thumbnail;
	var owner = image.owner ? 'owner: ' + image.owner : "";
	var datetaken = image.datetaken ? 'datetaken: ' + image.datetaken : "";
	var owner_desc = $('<div>').html(owner);
	datetaken = $('<div>').html(datetaken);
	var tag_desc = $('<div>').html(getWrapedText(image.tags, 50));
	var img = $('<img>').attr({'src': image_url, 'width': 200, 'height': 200});
	img = $('<div>').append($(img));
	$(block).append(img);
	$(block).append(owner_desc);
	$(block).append(datetaken);
	$(block).append(tag_desc);
	$('.image_preview').append($(block));	
	$('.image_preview').css({'top': event.pageY + 5, 'left': event.pageX + 5, 'z-index' : 30});
	$('.image_preview').show();
}

// When the mouse move on the interested image, the preview region move with the mouse.
function previewMove(event, json) {
	$('.image_preview').css({'top': event.pageY + 5, 'left': event.pageX + 5, 'z-index' : 30});
}

function previewHide() {
	$('.image_preview').fadeOut();
}

function getImageBlock(images, maxPerBlock, extraGroupData, width, imageSize){
	images = images.slice(0, maxPerBlock);

	if (!width) {
		width = 30;
	}
	if (!imageSize) {
		imageSize = 50;
	}
    var tmpDiv = $('<div>')
	
	var imageBlock = $('<div class="image_block">');
	imageBlock.css('display', 'inline-block').css('margin', '2px');

	var line = document.createElement("div");
	if (!extraGroupData) {
		line.innerHTML = '<b>Iconic Images Groups</b>';
	} else {
		line.innerHTML = '<b>' + extraGroupData.title + '</b>';		
	}
	imageBlock.append(line);
	
	var line = document.createElement("div");
	if (images && images[0]) {
		var lineText = '<b>Tags: </b>' + generateTagDesc(images, ',');
		lineText = getWrapedText(lineText, width);
		var userText = '<br><b>Users:</b><br>' + generateUserHist(images, 3);
		userText = getWrapedText(userText, width);
		lineText = lineText + userText;
		line.innerHTML = lineText;
		
	}
	imageBlock.append(line);
	
	line = $('<div>');
	var current_line_cnt = 0;
	if(!maxPerBlock || maxPerBlock == -1) {
		maxPerBlock = images.length;
	}		

	maxPerBlock = Math.min(images.length, maxPerBlock);
	var max_per_row = Math.round(Math.sqrt(maxPerBlock));
	var currentImageCount = 0;

	for(var i = 0;i < images.length && currentImageCount < maxPerBlock;i++){		
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
		img.attr('width', imageSize);
		img.attr('height', imageSize);		

		var newlink = $("<a>");
		newlink.attr('href', '#').attr('onclick', "window.open('" + imageUrl + "');");
		newlink.append(img);
		
		// Preview Images
		$(img).attr('onmouseover', 'preview(event, ' + JSON.stringify(images[i]) + ');');
		$(img).attr('onmousemove', 'previewMove(event, ' + JSON.stringify(images[i]) + ');');
		
		line.append(newlink);
		current_line_cnt ++;
		if (current_line_cnt == max_per_row) {
			current_line_cnt = 0;
			$(imageBlock).append(line);
			line = $("<div>");
		}
		currentImageCount ++;
	}
	$(imageBlock).append($(line));
	$(tmpDiv).append($(imageBlock));
	var ret = $(tmpDiv).html();
	return ret;
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

function getImageBlocks(allImageList, maxPerRow, start_id, extraGroupData, width, imageSize){
	if (!width) {
		width = 30;
	}
	if (!imageSize) {
		imageSize = 50;
	}
	var tmpDiv = $('<div>');

	console.log('Add image group');
	
    for(var row = 0;row < allImageList.length;row++){ 
		var images = allImageList[row];
		if (!images) {
			continue;
		}		
		imageBlock = $(getImageBlock(images, maxPerRow, extraGroupData, width, imageSize));		
		$(tmpDiv).append($(imageBlock));
    }
	return $(tmpDiv).html();
}  

function makeTableRows(divLists, colNum) {
	var table = $('<tbody>');
	for (var i = 0; i < divLists.length; ++i ) {
		var row = $('<tr>');
		divList = divLists[i];
		for (var c = 0; c < colNum; c++) {
			var col;
			if (c > 0) {
				col = $('<td>');				
			} else {
				col = $('<th>');
			}
			var item = '';
			if (c < divList.length) {
				item = divList[c];
			}
			col.html(item);
			row.append(col);
		}
		table.append(row);
	}
	return table.html();
}

function imageListsToTable(allImageLists, cols, maxPerRow, extraGroupData, width){
	if (!width) {
		width = 30;
	}
	if (!maxPerRow) {
		maxPerRow = -1;
	}
	if (!cols) {
		cols = 1;
	}
	var tmpDiv = $('<div>');
	var tbody = $('<tbody>');
	
	console.log('Add image lists table');
	divLists = [];
    for(var row = 0;row < allImageLists.length;row++){ 
		divList = [];
		imageList = allImageLists[row];
		for (var col = 0; col < imageList.length; ++col) {
			imageBlockHTML = getImageBlock(imageList[col], maxPerRow, extraGroupData, width);
			divList.push(imageBlockHTML);
		}
		divLists.push(divList);
    }
	$(tbody).append(makeTableRows(divLists, cols));
	$(tmpDiv).append($(tbody));
	return $(tmpDiv).html();
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

function generateUserHist(images, topN) {
	hist = {};
	ret = [];
	for (var i = 0; i < images.length; ++i) {
		items = images[i].owner;
		if (items == undefined) {
		  continue;
		}
		items = items.split(',');
		for (var j = 0; j < items.length; ++j) {
			count = hist[items[j]];
			if(count == undefined) {
				hist[items[j]] = 1;
			} else {
				hist[items[j]] = count + 1;			
			}
		}		
	}

	hist = getSortedTuple(hist);
	if (topN != -1) {
		topN = Math.min(topN, hist.length);
	} else {
		topN = hist.length;
	}
	for (var i = 0; i < topN; ++i) {
		ret.push(hist[i][0] + ":" + hist[i][1]);
	}
	return ret;
}

function getDisplayNavigationHTML(pageId, totPages) {
	var nav_div = $('<div>');
	
	item = $('<div>');
	$(item).css('fontWeight', 'bold');
	$(item).html('page ');
	nav_div.append(item);
	
	for (var i = 1; i <= totPages; ++i) {
		item = $('<div>');
		link = $('<a>');
		link.attr('href', '#').attr('onclick', "gotoPage(" + i + ");");
		link.html('' + i);
		if (pageId == i) {
			link.html('<b><font color="red">' + link.html() + '</font></b>');
		}
		item.append(link);
		nav_div.append(item);
	}	

	if (pageId < totPages) {
		nextPageLinkHref = "gotoPage(" + (pageId + 1) + ");";
		nextPageDiv = $('<div>');
		nextPageDiv.html('<a href="#" onclick="' + nextPageLinkHref + '">next page</a>');
		$(nav_div).append($(nextPageDiv));
	}
	
	if (pageId > 1) {
		prevPageLinkHref = "gotoPage(" + (pageId - 1) + ");";
		prevPageDiv = $('<div>').html('<a href="#" onclick="' + prevPageLinkHref + '">prev page</a>');;
		$(nav_div).append($(prevPageDiv));
	}
	return nav_div.html();
}