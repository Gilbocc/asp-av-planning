#include "common.asp".

% -------------------------------------
% World Modelling
% -------------------------------------

time(0..30).

% -------------------------------------
% Planning Problem
% -------------------------------------

% Maximum 1 action X per time T
0 { trace(T, X) : action(T, X) } 1 :- time(T).

% Must reach position g
goal :- fact(state(_, position(g))).
:- not goal.

fact(state(0, direction(forward))).

weight(X, 2) :- fact(traffic_light(_, X)).

#minimize { T@1, T, S : trace(T, S) }.
#minimize { W@1, T, S, W : trace(T, move(S)), weight(S, W) }.
#show trace/2.

% :- trace(T,move(b)), trace(T1,move(g)), not trace(T2, move(X)) : time(T2), node(X), X != b, X != g, T < T2 < T1.
