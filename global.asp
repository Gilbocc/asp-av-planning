% -------------------------------------
% World Modelling
% -------------------------------------

time(0..30).

node(a;b;c;d;e;f;g;x;y;z).

connected(a,b).
connected(b,g).
connected(a,c).       
connected(c,d).
connected(d,e).
connected(e,g).
connected(a,x).
connected(x,y).
connected(y,z).

fact(traffic_light(tl1, b)).
fact(traffic_light(tl2, d)).

fact(gas_station(gs1, y)).
fact(gas_station(gs2, e)).

next(T, X, Y) :- fact(state(T, direction(forward))), connected(X, Y).
next(T, X, Y) :- fact(state(T, direction(backward))), connected(Y, X).

invert(backward, forward).
invert(forward, backward).

% -------------------------------------
% World State
% -------------------------------------

% Inertia
fact(state(T+1, X)) :- fact(state(T, X)), time(T+1), not -fact(state(T+1, X)).

% -------------------------------------
% Available Actions
% -------------------------------------

% Preconditions
action(T, move(Y)) :- fact(state(T, position(X))), fact(state(T, fuel(F))), F > 0, next(T, X, Y), time(T+1).
action(T, invert(X)) :- fact(state(T, position(X))), time(T+1).
action(T, refuel(X)) :- fact(state(T, position(X))), fact(gas_station(_, X)), time(T+1).

% Postconditions
fact(state(T+1, position(X))) :- trace(T, move(X)).
fact(state(T+1, fuel(Y-1))) :- trace(T, move(_)), fact(state(T, fuel(Y))).
fact(state(T+1, direction(ND))) :- trace(T, invert(X)), fact(state(T, direction(D))), invert(D, ND).
fact(state(T+1, fuel(5))) :- trace(T, refuel(X)).

-fact(state(T+1, position(D))) :- trace(T, move(_)), fact(state(T, position(D))).
-fact(state(T+1, direction(D))) :- trace(T, invert(_)), fact(state(T, direction(D))).
-fact(state(T+1, fuel(D))) :- trace(T, refuel(_)), fact(state(T, fuel(D))).
-fact(state(T+1, fuel(D))) :- trace(T, move(_)), fact(state(T, fuel(D))).

% -------------------------------------
% Planning Problem
% -------------------------------------

% Maximum 1 action X per time T
0 { trace(T, X) : action(T, X) } 1 :- time(T).

% Must reach position g
goal :- fact(state(_, position(g))).
:- not goal.

% fact(state(0, position(a))).
fact(state(0, fuel(100))).
fact(state(0, direction(forward))).

weight(X, 2) :- fact(traffic_light(_, X)).

#minimize { T@1, T, S : trace(T, S) }.
#minimize { W@1, T, S, W : trace(T, move(S)), weight(S, W) }.
#show trace/2.

% :- trace(T,move(b)), trace(T1,move(g)), not trace(T2, move(X)) : time(T2), node(X), X != b, X != g, T < T2 < T1.