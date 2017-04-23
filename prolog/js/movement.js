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
var aim = 0.0;   // the aim for the cat on ground in sideways impulse
var catrot = 0.0;  // cat's spatial rotation
var cx = 1535.0;
var cy = 1193.0;
var aimdelta = 0.0;

function gameloop() {
	$("#keysink").focus();

	var cx = Number($("#cat").attr("cx"));
	var cy = Number($("#cat").attr("cy"));

	if (!flying) {
		if(charging) {
			charge += 5.0;
			charge = Math.min(50.0, charge);
			
			aim += aimdelta;
			if(aim < -3.0)aim = -3.0;
			if(aim > 3.0)aim = 3.0;
		}
		
		
		if(launch) {
			flying = true;
			charging = false;
			launch = false;
			
			var localr = Math.sqrt( (cx - myworldx) * (cx - myworldx) + (cy - myworldy) * (cy - myworldy) );

			catvx = charge * (cx - myworldx) / localr + aim * (cy - myworldy) / localr;
			catvy = charge * (cy - myworldy) / localr + aim * (cx - myworldx) / localr;
			// move cat free frame to get off ground
			cx += catvx * 1.5;
			cy += catvy * 1.5;
			charge = 0.0;
			aim = 0.0;			
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

function keydown(key) {
	if(key == 37)aimdelta = -0.2;
	else if(key == 39)aimdelta = 0.2;
	else if(key == 32 || key == 38)charging = true;
};

function keyup(key) {
	if(key == 32 || key == 38) {
		charging = false;
		launch = true;
	}
	if(key == 37 || key == 39)
		aimdelta = 0.0;

};

function requestFullScreen(element) {
    // Supports most browsers and their versions.
    var requestMethod = element.requestFullScreen || element.webkitRequestFullScreen || element.mozRequestFullScreen || element.msRequestFullScreen;

    if (requestMethod) { // Native full screen.
        requestMethod.call(element);
    } else if (typeof window.ActiveXObject !== "undefined") { // Older IE.
        var wscript = new ActiveXObject("WScript.Shell");
        if (wscript !== null) {
            wscript.SendKeys("{F11}");
        }
    }
}

$(function() {
     $("#keysink").focus().keydown(function(event) {
		console.log("down " + event.which);   // 37 left  38 up 39 right
                keydown(event.which);
	}).keyup(function(event) {
		console.log("up " + String(event.which));   // 37 left  38 up 39 right
                keyup(event.which);
	});
     window.setInterval(gameloop, 100);
     
     var elem = document.body; // Make the body go full screen.
     requestFullScreen(elem);
});



