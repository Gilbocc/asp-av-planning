% -------------------------------------
% World Modelling
% -------------------------------------

node(a;b;c;d;e;f;g;x;y;z).

connected(a,b).
connected(b,g).
connected(a,c).
connected(c,d).
connected(d,e).
connected(e,g).

fact(traffic_light(tl1, b)).
fact(traffic_light(tl2, d)).

fact(state(0, traffic_light(tl1, red))).

next(T, X, Y) :- fact(state(T, direction(forward))), connected(X, Y).
next(T, X, Y) :- fact(state(T, direction(backward))), connected(Y, X).

invert(backward, forward).
invert(forward, backward).

fact(state(T, traffic_light(tl2, red))) :- time(T), T \ 2 = 0.
-fact(state(T, traffic_light(tl2, green))) :- time(T), T \ 2 = 0.
fact(state(T, traffic_light(tl2, green))) :- time(T), T \ 2 = 1.
-fact(state(T, traffic_light(tl2, red))) :- time(T), T \ 2 = 1.

fact(state(T, traffic_light(tl3, red))) :- time(T), T \ 2 = 0.
-fact(state(T, traffic_light(tl3, green))) :- time(T), T \ 2 = 0.
fact(state(T, traffic_light(tl3, green))) :- time(T), T \ 2 = 1.
-fact(state(T, traffic_light(tl3, red))) :- time(T), T \ 2 = 1.

% -------------------------------------
% Available Actions
% -------------------------------------

% Preconditions
% Fuel:  fact(state(T, fuel(F))), F > 0,
action(T, move(Y)) :- fact(state(T, position(X))), next(T, X, Y), time(T+1).
action(T, invert(X)) :- fact(state(T, position(X))), time(T+1).

% Postconditions
fact(state(T+1, position(X))) :- trace(T, move(X)).
fact(state(T+1, direction(ND))) :- trace(T, invert(X)), fact(state(T, direction(D))), invert(D, ND).

-fact(state(T+1, position(D))) :- trace(T, move(_)), fact(state(T, position(D))).
-fact(state(T+1, direction(D))) :- trace(T, invert(_)), fact(state(T, direction(D))).

% Inertia
fact(state(T+1, X)) :- fact(state(T, X)), time(T+1), not -fact(state(T+1, X)).
