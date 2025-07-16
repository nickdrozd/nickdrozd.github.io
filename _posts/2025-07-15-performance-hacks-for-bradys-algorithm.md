---
title: "Performance Hacks for Brady's Algorithm"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2025-07-15 Tue&gt;</span></span>
layout: post
categories: 
tags: 
---

In the **Busy Beaver game** we ask: what is the longest that a **Turing machine program of *N* states and *K* colors** can run before halting when started on the blank tape? Answering this question requires **enumerating every such program** and checking whether or not it halts. But there is a big problem: there are just too many to check. The number of programs grows **multiple-exponentially** with *N* and *K*, ***O(nk<sup>nk</sup>)***. Yikes!

**[Brady's algorithm](https://nickdrozd.github.io/2022/01/14/bradys-algorithm.html)** is an enumeration technique that allays this situation somewhat. It is based on two observations. First, we know that the Turing machine programs will be run from the **blank tape**. This constrains the possible **execution paths**. An arbitary program may have instructions that are simply **unreachable** in these circumstances, and there is no need to consider such programs. Second, some programs are **isomorphic duplicates** of each other, differing only in having their states or colors rearranged. There is no need to consider these duplicates, and only one program from an isomorphic group will need to be considered.

So the algorithm goes like this. Start on the blank tape with a program whose only instruction is `A0:1RB`. Then run it until an undefined instruction is reached. Then enumerate all possible instructions, pursuant to the following restriction: **a new state can only be used if all prior states have been used**. For example, state `D` cannot be used until state `C` has been used, and state `E` cannot be used until state `D` has been used, etc. And likewise for colors. Then for each such instruction, create an **extension** of the program with that instruction inserted and **recursively continue the procedure**. This ensures that only programs with actually reachable and meaningfully distinct instructions are generated.

**It's a cool algorithm**, and a dramatic improvement over naive program generation. But even still, there are an awful lot of programs to generate, and running the algorithm can take quite a long time. So it is very important to pay attention to **fine implementation details** and take advantage of **low-level performance hacks** wherever possible. Small gains add up!

For some context, we will consider a **real-world, used-in-anger, known-good implementation** of Brady's algorithm written by **[Shawn and Terry Ligocki](https://github.com/sligocki/busy-beaver/blob/main/Code/TM_Enum.py)** and offer a few suggestions to make it faster. These are the sorts of changes that apply generically; **basically any implementation of the algorithm will deal with these same issues**. (Hopefully it goes without saying, but nothing here should be construed as negative or critical. This is fine code that has already proved its worth.)

There is some set-up to get the whole apparatus going. We will ignore all of that and jump straight into the action:

{% highlight python %}
class TM_Enum:
    def set_trans(self, *, state_in, symbol_in, symbol_out, dir_out, state_out): ...

    def enum_children(self, state_in, symbol_in):
        max_state = 0
        max_symbol = 0
        num_def_trans = 0

        for state in range(self.tm.num_states):
            for symbol in range(self.tm.num_symbols):
                trans = self.tm.get_trans_object(state_in=state, symbol_in=symbol)
                if trans.condition != Turing_Machine.UNDEFINED:
                    num_def_trans += 1
                    max_state = max(max_state, trans.state_out)
                    max_symbol = max(max_symbol, trans.symbol_out)

        num_states = min(self.tm.num_states, max_state + 2)
        num_symbols = min(self.tm.num_symbols, max_symbol + 2)

        if num_def_trans < self.max_transitions:
            for state_out in range(num_states):
                for symbol_out in range(num_symbols):
                    for dir_out in range(2):
                        new_tm_enum = copy.deepcopy(self)

                        new_tm_enum.set_trans(
                            state_in=state_in,
                            symbol_in=symbol_in,
                            symbol_out=symbol_out,
                            dir_out=dir_out,
                            state_out=state_out,
                        )

                        yield new_tm_enum
{% endhighlight %}

The outline of the procedure is clear: at the **branch point**, determine the available instructions based on the combination of already-used states and colors and maximum possible states and colors, then create extensions from them. There are **three easy ways to improve this**.


# Pass on used-parameter information from parent to child.

At the start of the branch, the program stops to check how many and which instructions it has used so far. But the parameters of the child program can be derived from the parameters of the parent program plus the extension instruction, so really **the program should already know this information about itself**. If each node keeps track of its parameter information and passes it on to its extensions, **the parameter recalculation can be skipped entirely**.


# Pre-calculate available instructions.

Given the available parameters, the available instructions are **generated on the fly every time**. But in practice the maximum available parameters are never all that large. So it is much faster to **generate a table of all possible available instructions just once up front**. Then the branching program can hold a reference to that table and index in with available parameters as needed. This will look something like:

{% highlight python %}
avail_instrs: list[Instruction] = self.table[avail_states][avail_colors]
{% endhighlight %}

Then at branch-time, obtaining available instructions is **just a fetch operation**, no generation required.


# Re-use the existing program.

With the instruction table approach, extension creation looks like this:

{% highlight python %}
for instr in avail_instrs:
    new_tm_enum = copy.deepcopy(self)
    new_tm_enum.set_trans(instr)  # or whatever
    yield new_tm_enum
{% endhighlight %}

We ran our program until it reached an undefined instruction, and now we are at the branch point, and we create one extended program for each available instruction. **Well, what happens to the program object we were just running?** Currently it gets **thrown in the trash**. But it is perfectly good and can continue to be used. And since the instructions are all there together, it is easy to accomplish this with some list manipulation:

{% highlight python %}
*rest_instrs, last_instr = avail_instrs

for instr in rest_instrs:
    new_tm_enum = copy.deepcopy(self)
    new_tm_enum.set_trans(instr)
    yield new_tm_enum

self.set_trans(last_instr)
yield self
{% endhighlight %}

This saves **one `deepcopy` call per branch** and also reduces the amount of **garbage** that must be collected.
