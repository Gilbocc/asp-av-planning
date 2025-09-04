import clingo
from clingo import Function, Application
import sys
import os

global_asp = "global.asp"
local_asp = "local.asp"

# Enable parallel mode in clingo
cpu_count = os.cpu_count() if os.cpu_count() else 1

class ClingoApp(Application):

    def __init__(self, name):
        self.program_name = name

    def main(self, ctl, files):
        print("Starting optimization...\n")
        self.select_action()

    def get_optimum_trace(self, global_asp_path, start, start_time, ignore=None):
        ctl = clingo.Control([f"--parallel-mode={cpu_count}"])
        ctl.load(global_asp_path)
        ctl.add("base", [], f"fact(state({start_time}, position({start}))).")
        # This should live elsewhere
        if ignore:
            facts = ignore[:2]
            print(f"Ignoring facts: {[str(x) for x in facts]}", "\n")
            A = facts[0].arguments[1].arguments[0].name
            B = facts[1].arguments[1].arguments[0].name
            # Exclude the ignored short path. From the ASP code
            ctl.add("base", [], f":- trace(T,move({A})), trace(T1,move({B})), not trace(T2, move(X)) : time(T2), node(X), X != {A}, X != {B}, T < T2 < T1.")
        ctl.ground([("base", [])])
        optimum_models = []
        min_cost = None

        def on_model(model):
            # print("\n", "Model:", model.symbols(shown=True), "Cost:", model.cost)
            nonlocal min_cost
            cost = model.cost if model.cost else 0
            if min_cost is None or cost < min_cost:
                min_cost = cost
                optimum_models.clear()
                optimum_models.append(model.symbols(shown=True))
            elif cost == min_cost:
                optimum_models.append(model.symbols(shown=True))

        ctl.solve(on_model=on_model)

        optimum_models.sort(key=len)
        return optimum_models, min_cost

    # Convert trace atoms to global_trace facts

    def trace_atoms_to_global_trace(self, atoms):
        facts = []
        for atom in atoms:
            arguments = atom.arguments
            facts.append(Function("global_trace", arguments))
        # print("\n", "Input trace atoms:", type(atoms))
        # print("Extracted trace atoms:", facts, "\n")
        facts.sort(key=lambda x: int(x.arguments[0].number))
        # There has to be a better way to do this...
        # string_facts = [str(x) + "." for x in facts]
        # print(f"Converted to global_trace facts: {string_facts}", "\n")
        return facts[:2]

    def get_local_trace(self, local, start, start_time, facts):
        string_facts = [str(x) + "." for x in facts]
        goal = facts[-1].arguments[-1].arguments[0]
        print("Getting local trace with facts:", string_facts, "from", start, "to", goal, "at", start_time, "\n")
        ctl = clingo.Control(["--warn=none", f"--parallel-mode={cpu_count}"])
        ctl.load(local)
        ctl.add("base", [], f"fact(state({start_time}, position({start}))).")
        ctl.add("base", [], f"fact(state({start_time}, direction(forward))).")
        ctl.add("base", [], f"time({start_time}..{start_time+2}).")
        ctl.add("base", [], f"goal :- fact(state(_, position({goal}))).\n:- not goal.")
        ctl.add("base", [], '\n'.join(string_facts))
        ctl.ground([("base", [])])
        proposed_models = []

        # Currently there is only one model returned here.
        def on_model(model):
            nonlocal proposed_models
            proposed_models.append(model.symbols(shown=True))

        ctl.solve(on_model=on_model)
        return proposed_models

    def destination_reached(self):
        print("Destination reached! \N{smiling face with sunglasses}", "\n")

    def run_short_path(self, global_trace, start, start_time):
        facts = self.trace_atoms_to_global_trace(global_trace)
        proposed_model = self.get_local_trace(local_asp, start, start_time, facts)
        if not proposed_model:
            print("No proposed model found.", "\n")
            # This shouldn't happen, but if there is no valid short term plan at all then call the long term planner again.
            self.select_action(ignore=global_trace, start=start, start_time=start_time)
        # If the proposed model is < 2 it means that either I am at my destination, or a single move will take me there.
        # Change with the short term plan.
        elif len(proposed_model[0]) < 2:
            self.destination_reached()
        else:
            print(f"Proposed {len(proposed_model)} local trace model: {proposed_model[0]}", "\n")
            # For now we assume we do not want violations
            # Replace with short term planner with preference as input. Should work by tweaking the minimize instructions
            # This then launches a global trace if there is no valid short term path
            if "violation" in str(proposed_model[0]):
                print("Violation detected in the proposed model. Rerouting from", start, start_time, "\n")
                # Hopefully this does not loop forever
                self.select_action(ignore=global_trace, start=start, start_time=start_time)
            else:
                print("No violation detected. Action accepted. Continuing...", "\n")
                new_trace = global_trace[2:]
                if new_trace == []:
                    self.destination_reached()
                    return
                new_start = global_trace[1].arguments[-1].arguments[0].name
                new_start_time = start_time + 2
                print("Remaining trace", [str(x) for x in new_trace], " from ", new_start, "\n")
                self.run_short_path(new_trace, new_start, new_start_time)

    def select_action(self, ignore=None, start="a", start_time=0):
        models, cost = self.get_optimum_trace(global_asp, start, start_time, ignore)
        print(f"Found {len(models)} optimum models with cost {cost}.", "\n")
        if models:
            global_trace = list(models[0])
            global_trace.sort(key=lambda x: x.arguments[0].number)
            print("Global trace:", [str(x) for x in global_trace], "\n")
            self.run_short_path(global_trace, start, start_time)
        else:
            print("No optimum trace found.", "\n")

if __name__ == "__main__":
    app = ClingoApp("auto_runner")
    sys.exit(clingo.clingo_main(app, ["--outf=3", "--warn=none", "--quiet=1"]))
