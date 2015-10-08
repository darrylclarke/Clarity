// Globals
BY_PERCENTAGE_LINES = 1;
BY_PERCENTAGE_FILES = 2;
BY_ABSOLUE_FILES = 3;
DEFAULT_COLOUR = "#d0e0eb";

metrics = {};
elements = [];
displayMode = BY_ABSOLUE_FILES;
includeNumberOnDisplay = false;

var setDisplayMode = function( mode )
{
	switch( mode )
	{
		case "BY_PERCENTAGE_LINES" :
			return BY_PERCENTAGE_LINES;
			break;
			
		case "BY_PERCENTAGE_FILES" :
			return BY_PERCENTAGE_FILES;
			break;
			
		case "BY_ABSOLUE_FILES"    :
			return BY_ABSOLUE_FILES;
			break;
			
		default :
			return BY_ABSOLUE_FILES
			break;
	}
}

var drawShape = function( context, folderNameFontSize, x_offset )
{
	context.fillStyle=this.colour;
	var displayNum = 0;
	
	switch( displayMode )
	{
		case BY_PERCENTAGE_LINES :
			context.fillStyle = getColourBasedOnPercentage( 
				displayNum = this.num_lines/metrics["total_lines"]*100 
				);
			break;
			
		case BY_PERCENTAGE_FILES :
			context.fillStyle = getColourBasedOnPercentage( 
				displayNum = this.num_code_files/metrics["total_num_code_files"]*100 
				);
			break;
			
		case BY_ABSOLUE_FILES    :
			context.fillStyle = getColourBasedOnNumberOfFiles( 
				displayNum = this.num_code_files 
				);
			break;
			
		default :
			context.fillStyle = DEFAULT_COLOUR;
			break;
	}
	context.fillRect(x_offset+this.left, this.top, this.width, this.height);

    labelWidth = context.measureText(this.text).width;
    labelOffset = (this.width - labelWidth)/2;
    context.fillStyle="#FFFFFF";
	context.fillRect( x_offset + this.left + labelOffset, this.top+this.height,
					  labelWidth, folderNameFontSize+2 );

    context.fillStyle="#000000"; 
    context.fillText(this.text,
        x_offset + this.left + labelOffset, this.top+this.height+folderNameFontSize);
		
	//context.fillText(""+this.num_code_files , x_offset + this.left + 2, this.top + folderNameFontSize + 2 )
	//context.fillText(""+this.folder_id , x_offset + this.left + 2, this.top + folderNameFontSize + 2 )
	if( includeNumberOnDisplay ) {
		displayNum = Math.round(displayNum)
		context.fillText(""+displayNum , x_offset + this.left + 2, this.top + folderNameFontSize + 2 )
	}
}

var getColourBasedOnNumberOfFiles = function( numFiles )
{
	if( numFiles == 0 )
		return DEFAULT_COLOUR;
	else if( numFiles > 0  && numFiles <= 5 )
		return "#49708A";
	else if( numFiles > 5  && numFiles <= 10 )
		return "#55708A";
	else if( numFiles > 10 && numFiles <= 15 )
		return "#66708A";
	else if( numFiles > 15 && numFiles <= 20 )
		return "#77708A";
	else if( numFiles > 20 && numFiles <= 30 )
		return "#88708A";
	else if( numFiles > 30 && numFiles <= 75 )
		return "#BB3545";
	else //if( numFiles > 75 )
		return "#FF0000";
}

var getColourBasedOnPercentage = function( percentage )
{
	if( percentage == 0 )
		return "#d0e0eb";
	else if( percentage > 0  && percentage <= 5 )
		return "#49708A";
	else if( percentage > 5  && percentage <= 10 )
		return "#55708A";
	else if( percentage > 10 && percentage <= 15 )
		return "#66708A";
	else if( percentage > 15 && percentage <= 20 )
		return "#77708A";
	else if( percentage > 20 && percentage <= 30 )
		return "#88708A";
	else if( percentage > 30 && percentage <= 75 )
		return "#BB3545";
	else //if( percentage > 75 )
		return "#FF0000";
}

var loadTree = function(data) {

	console.log("loadTree");
	console.log( data );
	
	var projectId = 0;
	elements = []; // no var, this is global
	
	for( var i = 0;  i < data.length;  i++ )
	{
		elements.push({
			text:           data[i].text,
			colour:         DEFAULT_COLOUR,
			width:          data[i].width,
			height:         data[i].height,
			top:            data[i].y_pos*100,
			left:           data[i].x_pos,
			folder_id:		data[i].folder_id,
			num_lines:		data[i].num_lines,
			num_code_files: data[i].num_code_files	
		})
	}
	projectId = data[0].project_id;	
	getLinks( projectId );
}

var getLinks = function(projectId) {
	$.ajax({
	method:  	"GET",
	url:		"http://localhost:3000/projects/"+ projectId + "/display_box_links.json",
	success:	displayLinks
	});
}

var displayLinks = function( data )
{
	console.log("displayLinks");
	console.log( data );
	
	var elem = document.getElementById('myCanvas');
	var elemLeft = elem.offsetLeft,
		elemTop = elem.offsetTop,
		context = elem.getContext('2d');	

	context.clearRect(0, 0, elem.width, elem.height);

	metrics = getMetrics( elements );
	var x_offset = metrics["x_offset"]; 

	for( var i = 0;  i < data.length;  i++ )
	{
		cell_from = elements[data[i].from];
		cell_to   = elements[data[i].to  ];
		
		drawLine( context, cell_from, cell_to, x_offset );
		console.log("line");
	}
	displayTree( elements, x_offset );
}
var drawLine = function( context, cell_from, cell_to, x_offset )
{
	var x1 = cell_from.left + cell_from.width/2;
	var y1 = cell_from.top  + cell_from.height/2;

	var x2 = cell_to.left + cell_to.width/2;
	var y2 = cell_to.top  + cell_to.height/2;

	context.moveTo(x_offset + x1,y1);
	context.lineTo(x_offset + x2,y2);
	context.stroke();
}

var getMetrics = function( elements )
{
	var max_width = 0;
	var total_lines = 0;
	var total_num_code_files = 0;
	
	for( var i = 0;  i < elements.length; i++ )
	{
		var element = elements[i];
		total_lines += element.num_lines;
		total_num_code_files += element.num_code_files;
		var max_x_element = element.left + element.width; 
		if( max_x_element > max_width )
		{
			max_width = max_x_element;
		}
	}
	if( max_width < 1100 )
	{
		metrics["x_offset"]= (1100 - max_width)/2;
	}
	else
	{
		metrics["x_offset"]= 0;
	}
	metrics["total_lines"] = total_lines;
	metrics["total_num_code_files"] = total_num_code_files;
	
	return metrics;
}

var displayTree = function(elements, x_offset) {
	// Add event listener for `click` events.
	var elem = document.getElementById('myCanvas');
	if( elem )
	{
		var elemLeft = elem.offsetLeft,
			elemTop = elem.offsetTop,
			context = elem.getContext('2d');

		var folderNameFontSize = 14;
		context.font = "" + folderNameFontSize + "px Arial";
		
		elements.forEach(function(e){
			e.draw = drawShape; 
			e.context = context;
			e.draw( context, folderNameFontSize, x_offset );
		});
		
		elem.addEventListener('click', function(event) {
			var x = event.pageX - elemLeft,
				y = event.pageY - elemTop;
		
			// Collision detection between clicked offset and element.
			elements.forEach(function(element) {
				if (y > element.top && y < element.top + element.height 
					&& x > (x_offset + element.left) && x < (x_offset + element.left + element.width)) {
					//alert('clicked element: ' + element.folder_id );
					window.location.href = "/folders/"+ element.folder_id;
				}
			});
		});
	}
}

$(document).ready(function(){
	$(document).on('submit', '#tree-options-form', function(e){
		e.preventDefault();
		displayMode = setDisplayMode( $("#tree-options-dropdown option:selected").val() );
		
		includeNumberOnDisplay = $("#displayCounts").is(':checked');
		console.log("draw " + displayMode + ", " + includeNumberOnDisplay  );
		displayTree( elements, metrics["x_offset"] );
	});

});


    

