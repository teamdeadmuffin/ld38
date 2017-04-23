var gamelooptimer;
var catvx = 12.0;
var catvy = 1.0;
var myworldx;   // when landed, xy for center of our world
var myworldy;  
var gconst = 1600000.0;      // was 1600000.0;
var flying = true;
var charging = false;
var charge = 0.0;
var launch = false;

// boundaries within which we wrap
var worldsizex = 65536.0;
var worldsizey = 65536.0;
var worldmarginx = 8196.0;
var worldmarginy = 8196.0;
var aim = 0.0;   // the aim for the cat on ground in sideways impulse
var catrot = 0.0;  // cat's spatial rotation
var cx = 32768.0;
var cy = 32768.0;
var aimdelta = 0.0;
var aimlimit = 300.0;

function gameloop() {
	$("#keysink").focus();

	if (!flying) {
		if(charging) {
			charge += 5.0;
			charge = Math.min(300.0, charge);
			
			aim += aimdelta;
			if(aim < -aimlimit)aim = -aimlimit;
			if(aim > aimlimit)aim = aimlimit;
		}
		
		if(launch) {
			flying = true;
			charging = false;
			launch = false;
			
			var localr = Math.sqrt( (cx - myworldx) * (cx - myworldx) + (cy - myworldy) * (cy - myworldy) );

			catvx = charge * (cx - myworldx) / localr + Math.min(charge, aim) * (cy - myworldy) / localr;
			catvy = charge * (cy - myworldy) / localr + Math.min(charge, aim) * (cx - myworldx) / localr;
			// move cat free frame to get off ground
			cx += catvx * 3.5;
			cy += catvy * 3.5;
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

	$("#asteroids use").each(function() {
			var acx = Number($(this).attr("gamex"));
			var acy = Number($(this).attr("gamey"));
			var grnd = 200;  // TODO make diff sized asteroids Number($(this).attr("r"));

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

	if(flying) {
		catvx = catvx + gx;
		catvy = catvy + gy;
		cx = cx + catvx;
		cy = cy + catvy;
		
		if (cx < worldmarginx)
			cx += worldsizex - worldmarginx;
		else if (cx > worldsizex - worldmarginx)
			cx -= worldsizex - worldmarginx;
			
		if (cy < worldmarginy)
			cy += worldsizey - worldmarginy;
		else if (cy > worldsizey - worldmarginy)
			cy -= worldsizey - worldmarginy;
			
		$("#cat").attr("cx", String(cx));
		$("#cat").attr("cy", String(cy));

		$("#scrollme").attr("transform", "translate(" + String(-cx + 512) + ", " + String(-cy + 512) + ")")
	} else {
		catvx = 0.0;
		catvy = 0.0;
	}
};

function keydown(key) {
	if(key == 37)aimdelta = -5;
	else if(key == 39)aimdelta = 5;
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



