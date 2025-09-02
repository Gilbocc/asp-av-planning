# OUTPUT

```
Starting optimization...

Found 1 optimum models with cost [3].

Global trace: [Function('trace', [Number(0), Function('move', [Function('b', [], True)], True)], True), Function('trace', [Number(1), Function('move', [Function('g', [], True)], True)], True)]

Extracted trace atoms: [Function('global_trace', [Number(0), Function('move', [Function('b', [], True)], True)], True), Function('global_trace', [Number(1), Function('move', [Function('g', [], True)], True)], True)]

Converted to global_trace facts: ['global_trace(0,move(b)).', 'global_trace(1,move(g)).']

Getting local trace with facts: ['global_trace(0,move(b)).', 'global_trace(1,move(g)).']  from  a

Proposed 1 local trace model: [violation(r1,stop(1,b),1), trace(0,move(b)), trace(1,move(g))]

Violation detected in the proposed model.

Ignoring facts: [Function('trace', [Number(0), Function('move', [Function('b', [], True)], True)], True), Function('trace', [Number(1), Function('move', [Function('g', [], True)], True)], True)]

Found 1 optimum models with cost [8].

Global trace: [Function('trace', [Number(0), Function('move', [Function('c', [], True)], True)], True), Function('trace', [Number(1), Function('move', [Function('d', [], True)], True)], True), Function('trace', [Number(2), Function('move', [Function('e', [], True)], True)], True), Function('trace', [Number(3), Function('move', [Function('g', [], True)], True)], True)]

Extracted trace atoms: [Function('global_trace', [Number(0), Function('move', [Function('c', [], True)], True)], True), Function('global_trace', [Number(1), Function('move', [Function('d', [], True)], True)], True), Function('global_trace', [Number(2), Function('move', [Function('e', [], True)], True)], True), Function('global_trace', [Number(3), Function('move', [Function('g', [], True)], True)], True)]

Converted to global_trace facts: ['global_trace(0,move(c)).', 'global_trace(1,move(d)).', 'global_trace(2,move(e)).', 'global_trace(3,move(g)).']

Getting local trace with facts: ['global_trace(0,move(c)).', 'global_trace(1,move(d)).']  from  a

Proposed 1 local trace model: [trace(0,move(c)), trace(1,move(d))]

No violation detected. Action accepted. Continuing...

Remaining trace [Function('trace', [Number(2), Function('move', [Function('e', [], True)], True)], True), Function('trace', [Number(3), Function('move', [Function('g', [], True)], True)], True)]  from  d

Extracted trace atoms: [Function('global_trace', [Number(2), Function('move', [Function('e', [], True)], True)], True), Function('global_trace', [Number(3), Function('move', [Function('g', [], True)], True)], True)]

Converted to global_trace facts: ['global_trace(2,move(e)).', 'global_trace(3,move(g)).']

Getting local trace with facts: ['global_trace(2,move(e)).', 'global_trace(3,move(g)).']  from  d

Proposed 1 local trace model: [trace(0,move(e)), trace(1,move(g))]

No violation detected. Action accepted. Continuing...

Remaining trace []  from  g

Extracted trace atoms: []

Converted to global_trace facts: []

Getting local trace with facts: []  from  g

Destination reached.
```