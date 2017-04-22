var gamelooptimer;
var catvx = 12.0;
var catvy = 6.0;
var gconst = 800000.0;
var flying = true;

function gameloop() {
	var cx = Number($("#cat").attr("cx"));
	var cy = Number($("#cat").attr("cy"));


// compute the local g

        var gx = 0.0;
        var gy = 0.0;

	$("#asteroids circle").each(function() {
			var acx = Number($(this).attr("cx"));
			var acy = Number($(this).attr("cy"));
			var grnd = Number($(this).attr("r"));

			var r = Math.sqrt((cx - acx)*(cx - acx) + (cy - acy) * (cy - acy) );
			var g = gconst / r / r;
			gx = gx + g * (acx - cx) / r;
			gy = gy + g * (acy - cy) / r;
			if(r < grnd) {
				flying = false;
			}
		});

	catvx = catvx + gx;
	catvy = catvy + gy;
	if(flying) {
		$("#cat").attr("cx", String(cx + catvx));
		$("#cat").attr("cy", String(cy + catvy));
	} else {
		catvx = 0.0;
		catvy = 0.0;
	}


};

$(function() {
     window.setInterval(gameloop, 100);
});
