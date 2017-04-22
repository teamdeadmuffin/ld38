var gamelooptimer;

function gameloop() {
	$("#cat").attr("cx", function(n, v) {
			return String(Number(v) + 3.0);
		});
};

$(function() {

     alert('called');

     window.setInterval(gameloop, 250);
});
