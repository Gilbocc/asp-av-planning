#include "Deontic/defeasible-ap.asp".
#include "Deontic/deontic-comp.asp".

#include "common.asp".

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
% World State
% -------------------------------------

%time(0..2).

%fact(state(0, fuel(2))).
fact(state(0, direction(forward))).
fact(state(0, traffic_light(tl1, red))).

% fact(state(T, traffic_light(tl2, red))) :- time(T), T \ 14 = 3.
% -fact(state(T, traffic_light(tl2, green))) :- time(T), T \ 14 = 3.
% fact(state(T, traffic_light(tl2, green))) :- time(T), T \ 14 = 5.
% -fact(state(T, traffic_light(tl2, red))) :- time(T), T \ 14 = 5.
fact(state(T, traffic_light(tl2, red))) :- time(T), T \ 14 = 7.
-fact(state(T, traffic_light(tl2, green))) :- time(T), T \ 14 = 7.

% -------------------------------------
% Planning Problem
% -------------------------------------

%time(0..4).
%fact(state(0, position(a))).
% Must reach position g

%goal :- fact(state(_, position(g))).
%:- not goal.

% 0 { trace(T, X) : action(T, X) } 1 :- time(T).
1 { trace(T, X) : time(T), action(T, X) } 1 :- global_trace(GT, X).

% :- global_trace(GT1, X1), global_trace(GT2, X2), GT1 < GT2, trace(T1, X1), trace(T2, X2), T1 >= T2.

% fact(emergency).

#minimize { 10@2 : obligation(pay_fine) }.
#minimize { T@1, T, S : trace(T, S) }.
#show trace/2.
#show violation/3.
