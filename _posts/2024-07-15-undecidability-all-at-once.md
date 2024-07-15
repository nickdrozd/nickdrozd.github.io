---
title: "What if undecidability shows up all at once?"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2024-07-15 Mon&gt;</span></span>
layout: post
categories: 
tags: 
---

The classic **Busy Beaver** function is defined as the maximum number of steps that an N-state 2-color Turing machine program can run before halting when started on the blank tape. The function is **uncomputable**, and any sound proof system *S* can only prove values up to a certain point. That is, there is some number *Q* such that

1.  *BB(Q) = K*,
2.  *S ⊬ BB(Q) = K*, and
3.  for all *P < Q*, *S ⊢ BB(P) = J* where *J = BB(P)*.

Call *Q<sub>S</sub>* the ***cut-off*** for *S*.

**Every theory has a cut-off.** There is *Q<sub>RA</sub>* for Robinson arithmetic, *Q<sub>PA</sub>* for Peano arithmetic, *Q<sub>ZF</sub>* for ZF set theory, *Q<sub>LC</sub>* for set theory with some large cardinal axiom, etc.

**What can be said about these cut-offs?** Certainly strengthening a system will not make it prove less, so when system *T* is more powerful than system *S*, we will have *Q<sub>S</sub> ≤ Q<sub>T</sub>*. Consequently, *Q<sub>RA</sub> ≤ Q<sub>PA</sub> ≤ Q<sub>ZF</sub> ≤ Q<sub>LC</sub>*.

Are these inequalities strict? It seems like they ought to be, and it would be convenient if they were. It could be that, say, *Q<sub>RA</sub> = 8*, *Q<sub>PA</sub> = 12*, *Q<sub>ZF</sub> = 27*, and *Q<sub>LC</sub> = 40*. This is the **[ladder picture](https://scottaaronson.blog/?p=4916#comment-1849770)** of Busy Beaver numbers. It says that we can imagine Busy Beaver numbers as rungs on a ladder, and every theory can be placed on its cut-off's rung. If the cut-offs are distinct, then we can see how the uncomputability of Busy Beaver ramps up as its values increase.

But that's all speculation. It could also be that [the cut-offs are all the same](https://scottaaronson.blog/?p=8088#comment-1981312): *Q<sub>RA</sub> = Q<sub>PA</sub> = Q<sub>ZF</sub> = Q<sub>LC</sub>*. According to this picture, the values of BB go provable, provable, provable, then BAM, unprovable. **All the undecidability shows up all at once**. In this scenario, there are no "degrees" of human-meaningful undecidability. All the systems that anybody cares about get stuck on the same rung of the ladder.

**How could this be?** There are several possibilities.

First, [the most straightforward way](https://arxiv.org/pdf/1605.04343) to establish that *S* cannot prove some value of *BB* is to devise a Turing machine program that enumerates theorems of *S* and halts if it finds a contradiction. This program will run forever if and only if *S* is consistent. But if *S* is consistent, then by the [second incompleteness theorem](https://nickdrozd.github.io/2018/08/13/incompleteness.html) it cannot prove its own consistency, and therefore cannot prove that the program will run forever. The program has *P* states, so *S* cannot prove the value of *BB(P)*.

Now, let *M<sub>PA</sub>* be the shortest program that implements this behavior for Peano arithmetic and let *M<sub>ZF</sub>* be the shortest program that does so for ZF set theory. What are the lengths of *M<sub>PA</sub>* and *M<sub>ZF</sub>*? For all that is known, they could have the same length. **This is less implausible than it might initially sound.** If *M<sub>PA</sub>* has *L* states, then no program of length less than *L* will be able to implement the contradiction-enumeration behavior for PA. There's no way to say why this should be the case, but by definition of *M<sub>PA</sub>*, it is. A number of states less than *L* just isn't enough to do the job. But *L* states might be enough for *M<sub>ZF</sub>*. It could be the case that once you have enough states to enumerate PA theorems, you have enough states to enumerate ZF theorems too.

There is another possibility. It could be that there is some statement say of number theory that is **easy to state and difficult to prove**, so difficult in fact that it cannot be proved in any of RA, PA, ZF, etc. And if there is a short TM program that computes this statement (say by halting if the statement is false), then if *L* is that program's length, none of these systems could prove *BB(L)*. As far as I know there is no reason to believe that this would be impossible.

**Okay, so what if all the cut-offs really are the same? What then?** One response is just to say that if the traditional Turing machine-based definition of Busy beaver is **too coarse-grained** to distinguish between these different proof systems, then that just shows that it's a bad definition, and we would be better off using something like [binary lambda calculus](https://oeis.org/A333479) instead. But any such formalism could still just as easily be affected by short-but-difficult statements.

But if these systems are all equivalent by the lights of the ladder picture, this could be viewed as a sort of proof that **people have been looking at the wrong proof systems**. There is an idea, very widespread and very stupid, that humans are inherently able to **"intuit" the consistency of formal systems**, using the "mind's eye" or maybe some kind of quantum mechanical magic. This is idea is clearly based on the presumed concistency of the usual formal systems PA, ZF, etc. But these systems are just a drop in the ocean of the full world of axiomatic systems. The systems that have been developed historically represent only a very small part of the solution space. Even if these systems are all on the same rung of the ladder, there are surely some systems that do exist on the higher rungs. **Well, what are those systems like?** That would be something to learn.

**Is any of this likely?** Well, it reasonable to expect that PA and ZF show up on different rungs, that *Q<sub>PA</sub> < Q<sub>ZF</sub>*. But the Busy Beaver function **grows uncomputably fast**. Any estimate of its growth is bound to be an underestimation. Any idea of "reasonable behavior" is probably wrong, because **the function is not reasonable**. Why should it be expected to make nice convenient stops at each widely used axiom system? Why shouldn't it blast right by?
