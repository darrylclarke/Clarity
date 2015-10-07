var code_class_code_namespace_id_reset = function(){
	$("select#code_class_code_namespace_id option").filter(function() {
   		 //may want to use $.trim in here
    	return $(this).text() == ""; 
	}).prop('selected', true);	
}

// $(window).load(function() {
//  // executes when complete page is fully loaded, including all frames, objects and images
//  alert("window is loaded");
// });

$(document).ready( function() {
	// alert("ready");
	// $("#code_class_code_namespace_id").prepend("<option value='-1'>(none)</option>");
	// $("#code_class_code_namespace_id").prepend("<option value=''></option>");
	// code_class_code_namespace_id_reset();

	//window.onload = function () { alert("loaded"); }

	// $("a#all-classes-link").on('click', function(e){
	// 	e.preventDefault
	// 	alert("hellok3k3k3k3k");
	// 	window.location.href = "/classes";
	// 	code_class_code_namespace_id_reset();
	// });
	
	$("#filter-by-namespace-reset").on('click', function(e){
		e.preventDefault(e);
		code_class_code_namespace_id_reset();
		window.location.href = "/classes";
	});
	
	$("#classes-index-namespace-search-form").on("submit", function(e){
		e.preventDefault(e);
		
		//$("#code_class_code_namespace_id option:selected").attr("value")
		
		var searchTerm = $("#code_class_code_namespace_id option:selected").text()
		//$("#namespace-name").val("");
		window.location.href = "/classes?filter_namespace="+ searchTerm;
	});
	
});
