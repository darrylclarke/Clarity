//var c = document.getElementById("myCanvas");
//var ctx = c.getContext("2d");
//ctx.fillStyle = "#FF0FF0";
//ctx.fillRect(0,0,150,75);

// var drawtree = function() 
// {
    
// }

// var tree
var drawShape = function( context, folderNameFontSize, x_offset )
{
	context.fillStyle=this.colour;
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
}

var getColourBasedOnNumberOfFiles = function( numFiles )
{
	if( numFiles == 0 )
		return "#d0e0eb"
	else if( numFiles > 0  && numFiles <= 5 )
		return "#49708A"
	else if( numFiles > 5  && numFiles <= 10 )
		return "#55708A"
	else if( numFiles > 10 && numFiles <= 15 )
		return "#66708A"
	else if( numFiles > 15 && numFiles <= 20 )
		return "#77708A"
	else if( numFiles > 20 && numFiles <= 30 )
		return "#88708A"
	else if( numFiles > 30 && numFiles <= 75 )
		return "#BB3545"
	else //if( numFiles > 75 )
		return "#FF0000"
}


// $(document).ready(function(){
// 	displayTree();
// });

elements = [];

var loadTree = function(data) {

	console.log("loadTree");
	console.log( data );
	
	var projectId = 0;
	elements = []; // no var, this is global
	
	for( var i = 0;  i < data.length;  i++ )
	{
		elements.push({
			text:           data[i].text,
			colour:         getColourBasedOnNumberOfFiles( data[i].num_code_files), //'#05EFFF',
			width:          data[i].width,
			height:         data[i].height,
			top:            data[i].y_pos*100,
			left:           data[i].x_pos,
			folder_id:		data[i].folder_id,
			num_code_files: data[i].num_code_files	
		})
	}
	projectId = data[0].project_id;
	
	// // Add element.
	// elements.push({
	// 	text: "hello",
	// 	colour: '#05EFFF',
	// 	width: 150,
	// 	height: 100,
	// 	top: 0,
	// 	left: 0
	// 	// ,
	// 	// draw : drawShape
	// });
	// elements.push({
	// 	text: "This is a long piece of text",
	// 	colour: '#0707FF',
	// 	width: 50,
	// 	height: 40,
	// 	top: 200,
	// 	left: 200
	// 	// ,
	// 	// draw : drawShape
	// });
			
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

	var x_offset = calculateXOffset( elements );

	for( var i = 0;  i < data.length;  i++ )
	{
		cell_from = elements[data[i].from];
		cell_to   = elements[data[i].to  ];
		
		drawLine( context, cell_from, cell_to, x_offset );
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

var calculateXOffset = function( elements )
{
	var max_width = 0;
	for( var i = 0;  i < elements.length; i++ )
	{
		var element = elements[i];
		var max_x_element = element.left + element.width; 
		if( max_x_element > max_width )
		{
			max_width = max_x_element;
		}
	}
	if( max_width < 1100 )
	{
		return (1100 - max_width)/2;
	}
	return 0;
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
					&& x > element.left && x < element.left + element.width) {
					//alert('clicked element: ' + element.folder_id );
					window.location.href = "/folders/"+ element.folder_id;
				}
			});
		});
	}
}


    

