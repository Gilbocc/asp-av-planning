#include "Deontic/defeasible-ap.asp".
#include "Deontic/deontic-comp.asp".

% -------------------------------------
% Rule r1/r2: Obligation to stop at traffic lights if red and not emergency
% -------------------------------------

prescriptiveRule(r1, stop(T, X)) :- tf(T, X).
applicable(r1, stop(T, X)) :- defeasible(traffic_light(ID, X)), defeasible(state(T, traffic_light(ID, red))).
compensate(r1, stop(T, X), pay_fine, 1) :- tf(T, X).

constitutiveRule(r2, non(stop(T, X))) :- tf(T, X).
applicable(r2, non(stop(T, X))) :- obligation(stop(T, X)), defeasible(state(T, position(X))), defeasible(trace(T, move(_))).
convertPermission(r2, non(stop(T, X))) :- defeasible(traffic_light(ID, X)), defeasible(state(T, traffic_light(ID, red))), defeasible(emergency).

fact(trace(T, move(X))) :- trace(T, move(X)).

atom(pay_fine).
atom(stop(T, X)) :- tf(T, X).

tf(T, X) :- fact(traffic_light(ID, X)), fact(state(T, traffic_light(ID, red))).

% -------------------------------------
% World Modelling
% -------------------------------------

time(0..2).

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

% fact(state(0, position(a))).
fact(state(0, fuel(2))).
fact(state(0, direction(forward))).
fact(state(0, traffic_light(tl1, red))).

fact(state(T, traffic_light(tl2, green))) :- time(T), T \ 14 = 0.
-fact(state(T, traffic_light(tl2, red))) :- time(T), T \ 14 = 0.
fact(state(T, traffic_light(tl2, red))) :- time(T), T \ 14 = 7.
-fact(state(T, traffic_light(tl2, green))) :- time(T), T \ 14 = 7.


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

% Inertia
fact(state(T+1, X)) :- fact(state(T, X)), time(T+1), not -fact(state(T+1, X)).

% -------------------------------------
% Planning Problem
% -------------------------------------

% global_trace(0,move(b)). 
% global_trace(1,move(g)).

1 { trace(T, X) : time(T), action(T, X) } 1 :- global_trace(GT, X).

:- global_trace(GT1, X1), global_trace(GT2, X2), GT1 < GT2, trace(T1, X1), trace(T2, X2), T1 >= T2.

% fact(emergency).

#minimize { 10@2 : obligation(pay_fine) }.
#minimize { T@1, T, S : trace(T, S) }.
#show trace/2.
#show violation/3.
