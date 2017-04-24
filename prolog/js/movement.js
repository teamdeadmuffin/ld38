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

			if (aim < 0)
				aim = Math.max(-charge, aim);
			else 
			   aim = Math.min(charge, aim);
			   
			console.log("aim " + String(aim));
			console.log("charge " + String(charge));
			
			catvx = charge * (cx - myworldx) / localr - aim * (cy - myworldy) / localr;
			catvy = charge * (cy - myworldy) / localr + aim * (cx - myworldx) / localr;
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

	$("#asteroids use.asteroid").each(function() {
			var acx = Number($(this).attr("gamex"));
			var acy = Number($(this).attr("gamey"));
			var grnd = Number($(this).attr("gamerad"));

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
				
				var asteroid = $(this).attr("gameid");  // caution - string!
				$("#asteroids use.powerup[asteroid='" + asteroid + "']").remove();
			}
		});
		


	   var earthr = Math.sqrt((cx - earthx)*(cx - earthx) + (cy - earthy) * (cy - earthy) );
		var gearth = gconst / earthr / earthr * 64.0;
		     
		gx = gx + gearth * (earthx - cx) / earthr;
		gy = gy + gearth * (earthy - cy) / earthr;
		if(earthr < 300.0) {
			console.log('win game');
			window.location.href = "/win";
		};	

	if(flying) {
		// move the cat
		catvx = catvx + gx;
		catvy = catvy + gy;
		cx = cx + catvx;
		cy = cy + catvy;
		
		// wrap the cat in the world
		if (cx < worldmarginx)
			cx += worldsizex - worldmarginx;
		else if (cx > worldsizex - worldmarginx)
			cx -= worldsizex - worldmarginx;
			
		if (cy < worldmarginy)
			cy += worldsizey - worldmarginy;
		else if (cy > worldsizey - worldmarginy)
			cy -= worldsizey - worldmarginy;
			
		// rotate the cat
	   catrot = 180.0 / 3.1416 * Math.atan2(gx, gy);

		if(isNaN(catrot)) catrot = 0.0;

		$("#cat").attr("transform", "translate(" + String(cx) + ", " + String(cy) + ") scale(-1 1) rotate(" + String(180.0 +catrot) + " 0 0)")

		$("#scrollme").attr("transform", "translate(" + String(-cx + 640) + ", " + String(-cy + 340) + ")");

/*  uncomment this, comment line above to rotate world
		$("#scrollme").attr("transform", "translate(" + String(640-cx) + ", " + String(520-cy) + ") rotate(" + (catrot) + 
		    " " + String(cx) + " " + String(cy) + ")");
	*/

	} else {
		catvx = 0.0;
		catvy = 0.0;
	}
};

function keydown(key) {
	if(key == 37)aimdelta = -10;
	else if(key == 39)aimdelta = 10;
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
                keydown(event.which);
	}).keyup(function(event) {
                keyup(event.which);
	});
     window.setInterval(gameloop, 100);

});



