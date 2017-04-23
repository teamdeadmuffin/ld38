:-module(main, [go/0,
                go/1]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/html_quasiquotations)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_files)).

http:location(js, '/js', []).
http:location(css, '/css', []).
http:location(img, '/img', []).
user:file_search_path(css, './css').
user:file_search_path(js, './js').
user:file_search_path(icons, './icons').

:- html_resource(jquery, [virtual(true), mime_type(text/javascript), requires('http://code.jquery.com/jquery-3.2.1.min.js')]).
:- html_resource(movement, [virtual(true), ordered(true), requires(['http://code.jquery.com/jquery-3.2.1.min.js', js('movement.js')])]).
:- html_resource(style, [virtual(true), requires([css('style.css')]), mime_type(text/css)]).

go :- go(8080).

go(Port) :-
    http_server(http_dispatch, [port(Port)]).

% :- http_handler(/, tut_page, []).
:- http_handler(/, main_page, []).

:- http_handler(js(.), http_reply_from_files('js/', []),
           [priority(1000), prefix]).
:- http_handler(css(.), http_reply_from_files('css/', []),
                [priority(1000), prefix]).
:- http_handler(img(.), http_reply_from_files('icons/', []),
                [priority(1000), prefix]).

main_page(_Request) :-
    reply_html_page(
        title('Félicette The Space Miner!'),
        \main_body
    ).

main_body -->
    html_requires(movement),
    html_requires(style),
    html(div(id('play-container'), \main_svg)),
    control_panel.

control_panel -->
    html(div(input([id(keysink), type(text)], []))).

main_svg -->
    contents_of_file(icons('svgheader.svf')),
    contents_of_file(icons('symbols.svf')),
    contents_of_file(icons('scrollmehdr.svf')),
    asteroids,
    contents_of_file(icons('svgtail.svf')).

asteroids -->
    asteroids(300, []).


marg(24576).

limits(N , Max) :-
    marg(N),
    Max is 65536 - N.

asteroids(0, _) --> [].
asteroids(N, AsteroidsSoFar) -->
    { succ(NN, N),
      repeat,
      limits(A,B),
      random_between(A, B, X),
      random_between(A, B, Y),
      debug(game, 'trying ~w ~w for ~w', [X, Y, N]),
      maplist(safe_location(X, Y), [32786.0-32786.0 | AsteroidsSoFar]), % include the cat
      random_between(1, 6, M),
      format(string(S) ,
 '<use xlink:href="#asteroid~w"  class="asteroid" id="a~w" width="404" height="404" x="-202" y="-201.999" transform="translate(~w ~w)" gamex="~w" gamey="~w" overflow="visible"/>~n', [M, N, X, Y, X, Y])
    },
    html(\[S]),
    !,
    asteroids(NN, [X-Y | AsteroidsSoFar]).


safe_location(X, Y, AX-AY) :-
    RSQ is (X - AX)* (X - AX) + (Y - AY) * (Y - AY),
    RSQ > 640000.  % 800 pixels distance


% transform was "matrix(1 0 0 -1 ~w ~w)

contents_of_file(File) -->
    {
    read_file_to_string(File, S, [])
    },
    html(\[S]).

/*
main_svg -->
    html(\["
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!-- Generator: Adobe Illustrator 15.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">
<svg version=\"1.1\" id=\"world\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
	 width=\"4096px\" height=\"4096px\" viewBox=\"0 0 4096 4096\" enable-background=\"new 0 0 4096 4096\" xml:space=\"preserve\">
<g id=\"starz\">
	<rect x=\"-46.911\" width=\"4189.822\" height=\"4096\"/>
	<polygon fill=\"#FFFF00\" points=\"948.364,906.636 870.252,871.133 796.723,915.352 806.351,830.092 741.574,773.826
		825.636,756.636 859.131,677.643 901.457,752.278 986.935,759.724 929.031,823.042		\"/>
	<polygon fill=\"#FFFF00\" points=\"543.818,1961.182 465.707,1925.678 392.178,1969.897 401.806,1884.638 337.029,1828.372
		421.091,1811.182 454.586,1732.188 496.911,1806.824 582.389,1814.27 524.485,1877.587	\"/>
	<polygon fill=\"#FFFF00\" points=\"1766.545,668.928 1688.434,633.424 1614.905,677.643 1624.533,592.384 1559.756,536.118
		1643.818,518.928 1677.313,439.935 1719.638,514.57 1805.116,522.016 1747.212,585.333	\"/>
	<polygon fill=\"#FFFF00\" points=\"2334.727,1144.345 2256.615,1108.841 2183.086,1153.06 2192.715,1067.801 2127.938,1011.535
		2212,994.345 2245.494,915.352 2287.82,989.987 2373.298,997.433 2315.395,1060.75		\"/>
	<polygon fill=\"#FFFF00\" points=\"1643.865,1903.436 1565.753,1867.932 1492.224,1912.151 1501.853,1826.892 1437.076,1770.625
		1521.138,1753.436 1554.632,1674.442 1596.958,1749.078 1682.436,1756.523 1624.533,1819.841	\"/>
	<polygon fill=\"#FFFF00\" points=\"948.363,2698.891 870.252,2663.387 796.723,2707.605 806.352,2622.346 741.574,2566.08
		825.637,2548.891 859.131,2469.896 901.457,2544.532 986.935,2551.979 929.031,2615.295	\"/>
	<polygon fill=\"#FFFF00\" points=\"666.498,3662.527 588.387,3627.023 514.857,3671.242 524.486,3585.982 459.709,3529.717
		543.771,3512.527 577.266,3433.533 619.592,3508.169 705.069,3515.615 647.166,3578.932	\"/>
	<polygon fill=\"#FFFF00\" points=\"2039.272,3321.618 1961.161,3286.114 1887.632,3330.333 1897.261,3245.073 1832.483,3188.808
		1916.546,3171.618 1950.04,3092.624 1992.366,3167.26 2077.844,3174.706 2019.94,3238.022	\"/>
	<polygon fill=\"#FFFF00\" points=\"3321.09,3617.072 3242.979,3581.568 3169.449,3625.787 3179.078,3540.527 3114.301,3484.262
		3198.363,3467.072 3231.857,3388.078 3274.184,3462.714 3359.662,3470.16 3301.758,3533.477	\"/>
	<polygon fill=\"#FFFF00\" points=\"3671.09,2461.183 3592.979,2425.679 3519.449,2469.897 3529.078,2384.638 3464.301,2328.372
		3548.363,2311.183 3581.857,2232.188 3624.184,2306.824 3709.662,2314.271 3651.758,2377.587	\"/>
	<polygon fill=\"#FFFF00\" points=\"3548.41,1382.054 3470.299,1346.55 3396.77,1390.769 3406.398,1305.509 3341.621,1249.244
		3425.684,1232.054 3459.178,1153.06 3501.504,1227.696 3586.982,1235.142 3529.078,1298.458	\"/>
	<polygon fill=\"#FFFF00\" points=\"3175.683,600.236 3097.571,564.732 3024.042,608.951 3033.671,523.691 2968.894,467.425
		3052.956,450.236 3086.45,371.242 3128.776,445.877 3214.255,453.324 3156.351,516.64	\"/>
	<polygon fill=\"#FFFF00\" points=\"2421.042,2389.799 2342.931,2354.296 2269.401,2398.514 2279.03,2313.256 2214.253,2256.989
		2298.315,2239.799 2331.81,2160.807 2374.136,2235.441 2459.614,2242.887 2401.71,2306.205		\"/>
	<polygon fill=\"#FFFF00\" points=\"443.818,447.545 365.707,412.042 292.178,456.261 301.806,371.001 237.029,314.735
		321.091,297.545 354.586,218.552 396.911,293.188 482.389,300.633 424.485,363.951		\"/>
</g>
<g id=\"asteroids\">
	<circle fill=\"#666666\" cx=\"2357.454\" cy=\"2841.952\" r=\"390.909\"/>
	<circle fill=\"#666666\" cx=\"2823.345\" cy=\"1193\" r=\"390.909\"/>
        <circle fill=\"#666666\" cx=\"3823.345\" cy=\"1893\" r=\"320\"/>
        <circle fill=\"#666666\" cx=\"8203.345\" cy=\"2000\" r=\"310\"/>
        <circle fill=\"#666666\" cx=\"1784\" cy=\"1956\" r=\"270\"/>
        <circle fill=\"#666666\" cx=\"3800\" cy=\"650\" r=\"200\"/>
</g>
<ellipse id=\"cat\" fill=\"#FE330A\" cx=\"1535.091\" cy=\"1193\" rx=\"79.545\" ry=\"88.637\"/>

"]).
*/
