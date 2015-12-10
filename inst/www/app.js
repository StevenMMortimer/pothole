$(document).ready(function () {
	//update the example curl line with the current server
  document.body.innerHTML = document.body.innerHTML.replace("https://{your_opencpu_server_address}/pothole/R/pothole_predict/json", 
		window.location.href.match(".*/pothole/")[0] + "R/pothole_predict/json"
	);
	
});

function csvScore() {
	//csv file scoring
	if(!$("#csvfile").val()) return;
	$("#outputcsv").addClass("hide").attr("href", "");
	$(".spinner").show();
	var req = ocpu.call("pothole_predict", {
		input : $("#csvfile")[0].files[0]
	}, function(tmp){
		$("#outputcsv").removeClass("hide").attr("href", tmp.getLoc() + "R/.val/csv");
	}).fail(function(){
		alert(req.responseText);
	}).always(function(){
		$(".spinner").hide();
	});
}

