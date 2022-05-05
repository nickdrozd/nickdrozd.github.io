---
title: "A Solution to the Halting Problem"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2022-05-05 Thu&gt;</span></span>
layout: post
categories:
tags:
---
Please excuse my **clickbait** title. It was intended to trigger the emotions of the kind of people who get worked up about computability theory. Of course I don't have a solution to the halting problem &#x2013; **there is no such thing**. Instead, I want to talk about a **partial solution** to the halting problem, a method to solve it for **certain instances**. And to make up for the misleading title, I'll also discuss how to extend the method to **other similar problems**.

The halting problem is this: **given a program, does it halt or not?** Sometimes the problem is stated in terms of a program run on an input, or a program run on something like its own source code. For our purposes, we'll consider a program to be **self-contained**, like a compiled binary that accepts no arguments.

A solution to the halting problem would be a **[total function](https://nickdrozd.github.io/2022/04/01/total-partial-functions.html)** with the type signature `Program -> Bool`. **Turing's Theorem** says that such a function cannot exist, and any function with that signature must be either **partial** or **incorrect**. (If this sounds similar to Gödel's Incompleteness Theorem, it's because [G's theorem follows directly from T's](https://scottaaronson.blog/?p=710).) Incorrect functions are bad, so we'll settle for partial. Or rather, the function we'll implement will declare a program to be non-halting only when it is **absolutely sure**; in the iffy cases, it won't declare the program to be nonhalting.

The term "program" is a bit vague. What kind of programs are we talking about here? Python? C? No, as usual we'll be talking about **[Turing machines](https://nickdrozd.github.io/2020/10/04/turing-machine-notation-and-normal-form.html)**. And there is even a specific application for this: the **[Busy Beaver game](https://nickdrozd.github.io/2020/10/15/busy-beaver-well-defined.html)**. The primary use here is in [paring down the search space](https://nickdrozd.github.io/2022/01/14/bradys-algorithm.html). The second use is in [proving the true values](https://nickdrozd.github.io/2020/12/15/lin-rado-proof.html) of the Busy Beaver function.

Following [Marxen and Buntrock](http://turbotm.de/~heiner/BB/mabu90.html), we can say that there are two methods for determining nonhaltingness: **forward reasoning** and **backward reasoning**. Reasoning forward means determining that the program will repeat some kind of behavior forever, and that therefore it will not halt. Detecting **[Lin recurrence](https://nickdrozd.github.io/2021/02/24/lin-recurrence-and-lins-algorithm.html)** is an example of forward reasoning. Reasoning backward means starting from the end of the program and showing that there is no possible path to the halt instruction. An **algorithm** for doing that is what we'll be concerned with here.

Now, there is one quick and easy way to tell that a program will never halt. **If there are no halt instructions, it definitely won't halt.** *Halt-free* programs can be dismissed out of hand, and the absence of a halt instruction can be checked using simple string functions. This kind of check belongs to **static analysis**.

The static instruction check can be applied to behaviors other than halting. Consider, for example, **[self-cleaning](https://nickdrozd.github.io/2021/07/11/self-cleaning-turing-machine.html)** Turing machines that erase all the marks on the tape. In order wipe the tape clean, a program must have at least one **erase instruction**, an instruction that prints a blank upon scanning a mark. If a program does not have any erase instructions &#x2013; and again, this is a quick and easy check &#x2013; then it definitely cannot be self-cleaning, and therefore can be ignored as a candidate for the **[Blanking Beaver](https://nickdrozd.github.io/2021/02/14/blanking-beavers.html)** problem.

For another example, consider the behavior known as ***[spinning out](https://groups.google.com/g/busy-beaver-discuss/c/Dq8PYAkoMXU)***. Here, the machine is scanning a blank cell directly to the left (or right) of all the marks on the tape, and the next instruction keeps control in the current state with a move to the left (or right). A machine in this circumstance will get "stuck" doing the same move forever. This is the simplest possible form of **[quasihalting](https://nickdrozd.github.io/2021/01/14/halt-quasihalt-recur.html)**, and all known **[Beeping Busy Beaver](https://nickdrozd.github.io/2022/02/11/latest-beeping-busy-beaver-results.html)** champions are spinners. There is an easy static check for this behavior: a program must have at least one ***zero-reflexive*** instruction, an instruction that keeps the state the same upon scanning a blank.

The halting problem asks whether a given program will halt, and along those same lines the **blank tape problem** and the **spin-out problem** ask whether a given program will blank the tape or spin out. An **oracular solution** for any one of these problems could be used to solve the other two, and so all three problems are **co-computable**.

**But in practice, the halting problem is easier.** We're assuming that programs are self-contained and run without input arguments of any kind, and therefore only one of a program's halt instructions can actually be executed. A common way to go about Busy Beaver searching is to discard out of hand any program with more than one halt instruction, since such a program has **wasted some of its precious few instructions**. But a program can have multiple erase or zero-reflexive instructions and they can all be used more than once.

The static analysis approach to the halting (blanking, spin-out) problem is **easy to implement** and **fast to run**. It makes for a great first pass. However, it's **shallow** and it leaves a lot on the table. There are programs that have the required instructions but still cannot halt (or wipe the tape, or spin out).

To show that these cannot reach their goals, we will **run the programs backwards**. Yes, we'll actually run them, and therefore this is a form of **dynamic analysis**. There are some downsides to the dynamic approach: it is slow, difficult to implement, and occasionally memory-intensive. The tradeoff is that it is **more thorough**, and it is capable of returning correct, definitive answers for a wider range of programs. (But it still isn't a general solution to the halting problem, because again, **there is no such thing**.)

The basic idea is that we will start from where we want to end up, and then work backwards from there. If we can **reconstruct a path to that endpoint** within a certain number of steps, then we will say that the program might reach that endpoint; on the other hand, if we can show that there is no possible path, then we can definitively say that the program will not reach that endpoint. In the latter case, we will have **solved that instance of the halting problem**.

This post has gone on for a while, and **describing algorithms is hard**, so I'm going to stop here and just post some code. This is **[real working code](https://github.com/nickdrozd/busy-beaver-stuff/blob/main/generate/program.py)** that has been [used for real](https://groups.google.com/g/busy-beaver-discuss/c/KofE0K7_AbQ). I'm posting it as-is &#x2013; no touch-ups, no tidying, none of that. *If anyone has actually read this far but finds the code unclear and wants further explanation of the backward-reasoning algorithm, please let me know and I'll write up another post.*

And with that, here's a (partial) solution to the halting (and blanking and spin-out) problem:

{% highlight python %}
class Program:
    # ... other stuff ...

    @property
    def cant_halt(self) -> bool:
        return self._cant_reach(
            'halted',
            self.halt_slots,
        )

    @property
    def cant_blank(self) -> bool:
        return self._cant_reach(
            'blanks',
            self.erase_slots,
            blank = True,
        )

    @property
    def cant_spin_out(self) -> bool:
        return self._cant_reach(
            'spnout',
            tuple(
                state + str(0) for state in
                self.graph.zero_reflexive_states),
        )

    def _cant_reach(
            self,
            final_prop: str,
            slots: Tuple[str, ...],
            max_attempts: int = 24,
            blank: bool = False,
    ):
        configs: List[
            Tuple[int, str, BlockTape, int, History]
        ] = [                              # type: ignore
            (
                1,
                state,                     # type: ignore
                BlockTape([], color, []),  # type: ignore
                0,
                History(),
            )
            for state, color in sorted(slots)
        ]

        comp = tcompile(str(self))

        max_repeats = max_attempts // 2

        seen: Dict[str, Set[str]] = defaultdict(set)

        while configs:  # pylint: disable = while-used
            step, state, tape, repeat, history = configs.pop()

            if step > max_attempts:
                return False

            if state == 'A' and tape.blank:
                return False

            if (tape_hash := str(tape)) in seen[state]:
                continue

            seen[state].add(tape_hash)

            history.add_state_at_step(step, state)  # type: ignore
            history.add_tape_at_step(step, tape)

            if history.check_for_recurrence(
                    step,
                    (state, tape.scan)) is None:  # type: ignore
                repeat = 0
            else:
                repeat += 1

                if repeat > max_repeats:
                    continue

            history.add_action_at_step(
                step,
                (state, tape.scan)) # type: ignore

            # print(step, state, tape)

            for entry in sorted(self.graph.entry_points[state]):
                for _, (_, shift, trans) in self[entry].items():
                    if trans != state:
                        continue

                    for color in sorted(map(int, self.colors)):
                        next_tape = tape.copy()

                        _ = next_tape.step(
                            not (0 if shift == 'L' else 1),
                            next_tape.scan,
                        )

                        next_tape.scan = color

                        run = Machine(comp).run(
                            step_lim = step + 1,
                            tape = next_tape.copy(),
                            state = ord(entry) - 65,
                            check_blanks = blank,
                        )

                        result = getattr(run.final, final_prop)

                        if result is None:
                            if run.final.undfnd is None:
                                continue

                            result = step + 1

                        if abs(result - step) > 1:
                            continue

                        configs.append((
                            step + 1,
                            entry,
                            next_tape,
                            repeat,
                            history.copy(),
                        ))

        return True
{% endhighlight %}
