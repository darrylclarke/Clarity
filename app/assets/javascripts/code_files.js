$(document).ready( function() {
	
	$(document).on('click', '#code-file-show-page-hide-code', function(e){
		e.preventDefault();
		$("#code-file-show-page-code-block").fadeOut(500);
	});
});