:-module(main, [go/0,
                go/1]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_files)).

http:location(js, '/js', []).
http:location(css, '/css', []).
http:location(img, '/img', []).
http:location(audio, '/audio', []).
user:file_search_path(css, './css').
user:file_search_path(js, './js').
user:file_search_path(icons, './icons').
user:file_search_path(audio, './audio').

:- html_resource(jquery, [virtual(true), mime_type(text/javascript), requires('http://code.jquery.com/jquery-3.2.1.min.js')]).
:- html_resource(movement, [virtual(true), ordered(true), requires(['http://code.jquery.com/jquery-3.2.1.min.js', js('movement.js')])]).
:- html_resource(style, [virtual(true), requires([css('style.css')]), mime_type(text/css)]).

go :- go(8080).

go(Port) :-
    http_server(http_dispatch, [port(Port), timeout(1200), workers(16)]).

% :- http_handler(/, tut_page, []).
:- http_handler('/game', main_page, []).
:- http_handler('/', tut_page, []).
:- http_handler('/win', win_page, []).
:- http_handler('/lose', lose_page, []).


:- http_handler(js(.), http_reply_from_files('js/', []),
           [priority(1000), prefix]).
:- http_handler(css(.), http_reply_from_files('css/', []),
                [priority(1000), prefix]).
:- http_handler(img(.), http_reply_from_files('icons/', []),
                [priority(1000), prefix]).
:- http_handler(audio(.), http_reply_from_files('audio/', [time_limit(infinite)]),
                [priority(1000), prefix]).


tut_page(_Request) :-
    reply_html_page(
        title('Félicette In Space'),
        \tut_body
    ).

tut_body -->
    html_requires(style),
    html(div(id(tutbody), [
             div(img([class(logo), src('/img/titlewebcs5.jpg')])),
             div([img([class(tut), src('/img/tut1.png')]),
                  img([class(tut), src('/img/tut2.png')]),
                  img([class(tut), src('/img/tut3.png')])
                 ])
         ])).

win_page(_Request) :-
    reply_html_page(
        title('Félicette In Space'),
        \win_body
    ).

win_body -->
    html(div([p('Win page'), a(href='/game', 'RESTART')])).

lose_page(_Request) :-
    reply_html_page(
        title('Félicette In Space'),
        \lose_body
    ).

lose_body -->
    html(div([p('lose page'), a(href='/game', 'RESTART')])).

user:body(game, Body) -->
        html(body(class(game), Body)).

main_page(_Request) :-
    reply_html_page(
        game,
        title('Félicette In Space'),
        \main_body
    ).

main_body -->
    html_requires(movement),
    html_requires(style),
    html(div(id('play-container'), \main_svg)),
    control_panel.

control_panel -->
    {
        random_member(Src, ['/audio/finding_way_home.mp3', '/audio/loop2.mp3'])
    },
    html([div(input([id(keysink), type(text)], [])),
         audio([loop(true), src(Src), autoplay(true)], []),
         audio([src('/audio/crystal0.mp3')], []),
         audio([id(oxygenpick), src('/audio/oxygen_pick.mp3')], [])
         ]).

main_svg -->
    {
         locate_earth(EarthX, EarthY),
    format(string(JS), '<script>var earthx=~w;  var earthy=~w;</script>', [EarthX, EarthY])
    },
    html(\[JS]),
    contents_of_file(icons('svgheader.svf')),
    contents_of_file(icons('symbols.svf')),
    contents_of_file(icons('rocket.svf')),
    contents_of_file(icons('scrollmehdr.svf')),
    {
        format(string(S), '<use xlink:href="#earth_1_"  id="earth" width="900.8" height="1024" x="-450.4" y="-512" transform="translate(~w ~w)" style="overflow:visible;"/><g id="asteroids" >', [EarthX, EarthY])
    },
    html(\[S]),
    asteroids,
    contents_of_file(icons('svgtail.svf')).

locate_earth(EarthX, EarthY) :-
    repeat,
    random_between(4096, 57344, EarthX),
    random_between(4096, 57344, EarthY),
    (   EarthX < 24567 ; EarthX > 40960),
    (   EarthY < 24567 ; EarthY > 40960).



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
      RadScale is (6.0 + 6.0 * random_float) / 10.0,
      GRad is 200.0 * RadScale + 60.0,
      Exclusion is 200.0 * RadScale * 2.0,
      maplist(safe_location(X, Y, Exclusion), [32786.0-32786.0-360.0 | AsteroidsSoFar]), % include the cat
      random_between(1, 6, M),
      random_between(0, 359, R),
      format(string(S) ,
 '<use xlink:href="#asteroid~w"  class="asteroid" id="a~w" gameid="~w" width="404" height="404" x="-202" y="-201.999" transform="translate(~w ~w) scale(~w) rotate(~w 0 0)" gamerad="~w" gamex="~w" gamey="~w" overflow="visible"/>~n', [M, N, N, X, Y, RadScale, R, GRad, X, Y])
    },
    html(\[S]),
    crystals_for(N, X, Y, RadScale, _Points, _Oxygen),   % DARN IT JAN
    !,
    asteroids(NN, [X-Y-Exclusion | AsteroidsSoFar]).

crystals_for(Asteroid, X, Y, RadScale, Points, Oxygen) -->
    {
    random_member(Red, [0,1,2]),
    random_member(Green, [0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2]),
    random_member(Blue, [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]),

    Pox is random_float,
    (   Pox > 0.9
    ->  Oxygen = 1
    ;   Oxygen = 0
    ),
    Points is Red + 5 * Green + 50 * Blue
    },
    powerup('red-crystal', Asteroid, X, Y, RadScale, Red),
    powerup('green-crystal', Asteroid, X, Y, RadScale, Green),
    powerup('blue-crystal', Asteroid, X, Y, RadScale, Blue),
    powerup(oxygen, Asteroid, X, Y, RadScale, Oxygen).

powerup(_Class, _Asteroid, _X, _Y, _RadScale, 0) --> [].
powerup(Class, Asteroid, X, Y, RadScale, N) -->
    {
         succ(NN, N),
         R is 200.0 * RadScale,
         powerup_(Class, Asteroid, X, Y, R, S)
    },
    html(\[S]),
    powerup(Class, Asteroid, X, Y, RadScale, NN).

powerup_('red-crystal', Asteroid, X, Y, R, S) :-
      random_between(0, 359, Rot),
      random_between(-15, 15, Rot2),
      format(string(S) ,
             '<use xlink:href="#crystal3" class="powerup crystal" width="50.797" height="93.546" x="-25.399" y="-46.773" transform="translate(~w ~w) rotate(~w 0 0) translate(0 ~w) rotate(~w 0 0)" asteroid="~w" overflow="visible"/>', [X, Y,Rot, R, Rot2, Asteroid]).
powerup_('green-crystal', Asteroid, X, Y, R, S) :-
      random_between(0, 359, Rot),
      random_between(-15, 15, Rot2),
      format(string(S) ,
             '<use xlink:href="#crystal1" class="powerup crystal"  width="50.797" height="93.546" x="-25.399" y="-46.773" transform="translate(~w ~w) rotate(~w 0 0) translate(0 ~w) rotate(~w 0 0)" asteroid="~w" overflow="visible"/>', [X, Y,Rot, R, Rot2, Asteroid]).
powerup_('blue-crystal', Asteroid, X, Y, R, S) :-
      random_between(0, 359, Rot),
      random_between(-15, 15, Rot2),
      format(string(S) ,
             '<use xlink:href="#crystal2" class="powerup crystal"  width="50.797" height="93.546" x="-25.399" y="-46.773" transform="translate(~w ~w) rotate(~w 0 0) translate(0 ~w) rotate(~w 0 0)" asteroid="~w" overflow="visible"/>', [X, Y,Rot, R, Rot2, Asteroid]).
powerup_(oxygen, Asteroid, X, Y, R, S) :-
      random_between(0, 359, Rot),
      random_between(-45, 45, Rot2),
      RR is random_float * R,
      format(string(S) ,
             '<use xlink:href="#oxygen" class="powerup oxygen"  width="56.667" height="144.778" x="-28.334" y="-72.389" transform="translate(~w ~w) rotate(~w 0 0) translate(0 ~w) rotate(~w 0 0)" asteroid="~w" overflow="visible"/>', [X, Y,Rot, RR, Rot2, Asteroid]).

safe_location(X, Y, MyExclusion, AX-AY-R) :-
    RSQ is (X - AX)* (X - AX) + (Y - AY) * (Y - AY),
    RSQ > (R + MyExclusion) * (R + MyExclusion).  % 800 pixels distance

contents_of_file(File) -->
    {
    read_file_to_string(File, S, [])
    },
    html(\[S]).

