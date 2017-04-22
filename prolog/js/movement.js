var gamelooptimer;
var catvx = 12.0;
var catvy = 1.0;
var myworldx;
var myworldy;
var gconst = 1600000.0;
var flying = true;
var charging = false;
var charge = 0.0;
var launch = false;
var worldsizex = 4096.0;
var worldsizey = 4096.0;
var catrot = 0.0;

function gameloop() {
	$("#keysink").focus();

	var cx = Number($("#cat").attr("cx"));
	var cy = Number($("#cat").attr("cy"));

	if (!flying) {
		if(charging) {
			charge += 5.0;
			charge = Math.min(50.0, charge);
		}
		
		if(launch) {
			flying = true;
			charging = false;
			launch = false;
			
			var localr = Math.sqrt( (cx - myworldx) * (cx - myworldx) + (cy - myworldy) * (cy - myworldy) );

			catvx = charge * (cx - myworldx) / localr + catrot * (cy - myworldy) / localr;
			catvy = charge * (cy - myworldy) / localr + catrot * (cx - myworldx) / localr;
			// move cat free frame to get off ground
			cx += catvx * 1.5;
			cy += catvy * 1.5;
			charge = 0.0;
			catrot = 0.0;			
		} else {
			return;
		}
	}

	console.log('applying physics');

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
				catvx = 0.0;
				catvy = 0.0;
 				myworldx = acx;
				myworldy = acy;
			}
		});

	catvx = catvx + gx;
	catvy = catvy + gy;

	if(flying) {
		var newcx = cx + catvx;
		var newcy = cy + catvy;
		
		if (newcx < 0.0)
			newcx += worldsizex;
		else if (newcx > worldsizex)
			newcx -= worldsizex;
			
		if (newcy < 0.0)
			newcy += worldsizey;
		else if (newcy > worldsizey)
			newcy -= worldsizey;
			
		$("#cat").attr("cx", String(cx + catvx));
		$("#cat").attr("cy", String(cy + catvy));
	} else {
		catvx = 0.0;
		catvy = 0.0;
	}
};

function rotaterocket(rot) {
    catrot += rot;
    if (catrot < -3.0)catrot = -3.0;
    else if (catrot > 3.0)catrot = 3.0;
    console.log('catrot ' + catrot);
};

function keydown(key) {
	if(key == 37)rotaterocket(-0.2);
	else if(key == 39)rotaterocket(0.2);
	else if(key == 32 || key == 38)charging = true;
};

function keyup(key) {
	if(key == 32 || key == 38) {
		charging = false;
		launch = true;
	}

};

$(function() {
     $("#keysink").focus().keydown(function(event) {
		console.log("down " + event.which);   // 37 left  38 up 39 right
                keydown(event.which);
	}).keyup(function(event) {
		console.log("up " + String(event.which));   // 37 left  38 up 39 right
                keyup(event.which);
	});
     window.setInterval(gameloop, 100);
});



