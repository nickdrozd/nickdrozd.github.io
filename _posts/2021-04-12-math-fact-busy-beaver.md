---
title: "A Mathematical Fact from a Busy Beaver"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-04-12 Mon&gt;</span></span>
layout: post
categories:
tags:
---
Consider the following **number sequence**:

{% highlight nil %}
2, 7, 15, 27, 45, 69
{% endhighlight %}

Can you figure out the next entry? If so, top marks for you. If not, the thing to do is check out the **[Online Encyclopedia of Integer Sequences](https://oeis.org/)**. As it happens, there is **[exactly one sequence](https://oeis.org/search?q=2%2C7%2C15%2C27%2C45%2C69)** containing those numbers as a subsequence, namely sequence [A061802](https://oeis.org/A061802). That sequence is defined as the ***sums of the rows of a certain prime number pyramid***:

{% highlight nil %}
1 |                2                |  2
2 |             2  3  2             |  7
3 |          2  3  5  3  2          | 15
4 |       2  3  5  7  5  3  2       | 27
5 |    2  3  5  7 11  7  5  3  2    | 45
6 | 2  3  5  7 11 13 11  7  5  3  2 | 69
{% endhighlight %}

The OEIS doesn't have any other entries with that subsequence, so it is not unreasonable to assume that **this is the only known method for generating that sequence**. But I didn't come across these numbers from looking at the prime number pyramid. Instead, I found it from looking at a **Turing machine program**:

|---|---|---|---|---|
| | `A` | `B` | `C` | `D` |
|---|---|---|---|---|
| `0` | `1RB` | `1LC` | `1RA` | `0RD` |
|---|---|---|---|---|
| `1` | `1RC` | `1RD` | `1LD` | `0LB` |
|---|---|---|---|---|

Or in [string notation](https://nickdrozd.github.io/2020/10/04/turing-machine-notation-and-normal-form.html): `1RB 1RC 1LC 1RD 1RA 1LD 0RD 0LB`.

When run on the blank tape, this 4-state 2-color program **[quasihalts](https://nickdrozd.github.io/2021/01/14/halt-quasihalt-recur.html) in 2819 steps**, dropping into [Lin recurrence](https://nickdrozd.github.io/2021/02/24/lin-recurrence-and-lins-algorithm.html) with a period of just one step. From [9 August 2020](https://www.scottaaronson.com/blog/?p=4916#comment-1852398) to [17 September 2020](https://www.scottaaronson.com/blog/?p=4916#comment-1857234) it reigned as the **[Beeping Busy Beaver champion](https://nickdrozd.github.io/2020/08/13/beeping-busy-beavers.html)**.

Usually a Turing machine is understood to **communicate the results of its computation** by whatever is left over on the tape when it stops running. But suppose instead the Turing machine is hooked up to some kind of **printing device**, and it communicates output under the following conditions:

1.  all the marks on the tape form a single contiguous block, and
2.  that block is the longest span of marks on the tape up to that point in the computation.

If those conditions obtain, suppose that the length of that block of marks will be interpreted as a number written in **unary notation**, and it will be printed. Note that these conditions are both **computable**, and so could be handled by a reasonably simple [Turing machine simulator](https://nickdrozd.github.io/2020/09/14/programmable-turing-machine.html).

Now here's the shocking truth: **if you run that program under that output regime, you will get the first few terms of the prime pyramid sequence**.

I choked on my coffee when I realized this. Remember, the prime pyramid sequence is apparently the only known method of obtaining that subsequence. So it appears, against all odds, that **this Turing machine program understands prime numbers**. Prime numbers aren't the most complicated math concept around, but they are probably more complicated than you realize if you have never tried to [define them to a theorem prover](https://nickdrozd.github.io/2020/04/26/idris-algebra.html). So it would be truly astonishing if such a short program in such a primitive language could be capable of expressing facts about prime numbers.

Okay, but if that's true, **how does it actually work?** What is it doing? [A program is an expression of a computational process](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-9.html#%_chap_1) &#x2013; so what process is it? Could the program somehow be using a **novel algorithm** to calculate these numbers?

At this point it's important to keep in mind that, except perhaps in some broad cosmic sense, **this program was not "written" by anyone**. There are debates about whether mathematics is "discovered" or "invented". I can personally testify that **this program was *discovered*** in the strictest sense of that word. I was the one who discovered it. One day I fired up my laptop and started a search over the space of 4-state 2-color Turing machine programs, and eventually this program popped up on the screen. So any **normative talk** we might use to discuss the program &#x2013; what it's "trying to do", its "goal", any "bugs" it might have &#x2013; is totally foreign to and imposed upon the program itself.

That said, let's look at a slice of the program's **tape evolution**. A useful technique in analyzing Turing machine tapes is to **only print the tape when the machine is in a certain state**. This cuts down on a lot of the repetitive parts of the computation and gives a useful time-lapse cross-section. Here is the first section of execution when only state `A` is printed:

{% highlight nil %}
  0 A __________________________________________________
  7 A ________________________#_##______________________
  9 A ________________________####______________________
 11 A _______________________#####______________________
 29 A _____________________#_#_##_##____________________
 31 A _____________________#_#_#####____________________
 49 A _____________________#_#__#_#_##__________________
 51 A _____________________#_#__#_####__________________
 53 A _____________________#_#__######__________________
 55 A _____________________#_#_#######__________________
 89 A ______________________#_#_#_#_#_##________________
 91 A ______________________#_#_#_#_####________________
 93 A ______________________#_#_#_######________________
 95 A ______________________#_#_########________________
 97 A ______________________#_##########________________
 99 A ______________________############________________
101 A _____________________#############________________
143 A ___________________#_#_#_#_#_#_##_##______________
145 A ___________________#_#_#_#_#_#_#####______________
163 A ___________________#_#_#_#_#_#__#_#_##____________
165 A ___________________#_#_#_#_#_#__#_####____________
167 A ___________________#_#_#_#_#_#__######____________
169 A ___________________#_#_#_#_#_#_#######____________
203 A ___________________#_#_#_#__#_#_#_#_#_##__________
205 A ___________________#_#_#_#__#_#_#_#_####__________
207 A ___________________#_#_#_#__#_#_#_######__________
209 A ___________________#_#_#_#__#_#_########__________
211 A ___________________#_#_#_#__#_##########__________
213 A ___________________#_#_#_#__############__________
215 A ___________________#_#_#_#_#############__________
267 A ___________________#_#__#_#_#_#_#_#_#_#_##________
269 A ___________________#_#__#_#_#_#_#_#_#_####________
271 A ___________________#_#__#_#_#_#_#_#_######________
273 A ___________________#_#__#_#_#_#_#_########________
275 A ___________________#_#__#_#_#_#_##########________
277 A ___________________#_#__#_#_#_############________
279 A ___________________#_#__#_#_##############________
281 A ___________________#_#__#_################________
283 A ___________________#_#__##################________
285 A ___________________#_#_###################________
355 A ____________________#_#_#_#_#_#_#_#_#_#_#_##______
357 A ____________________#_#_#_#_#_#_#_#_#_#_####______
359 A ____________________#_#_#_#_#_#_#_#_#_######______
361 A ____________________#_#_#_#_#_#_#_#_########______
363 A ____________________#_#_#_#_#_#_#_##########______
365 A ____________________#_#_#_#_#_#_############______
367 A ____________________#_#_#_#_#_##############______
369 A ____________________#_#_#_#_################______
371 A ____________________#_#_#_##################______
373 A ____________________#_#_####################______
375 A ____________________#_######################______
377 A ____________________########################______
379 A ___________________#########################______
457 A _________________#_#_#_#_#_#_#_#_#_#_#_#_##_##____
459 A _________________#_#_#_#_#_#_#_#_#_#_#_#_#####____
477 A _________________#_#_#_#_#_#_#_#_#_#_#_#__#_#_##__
479 A _________________#_#_#_#_#_#_#_#_#_#_#_#__#_####__
481 A _________________#_#_#_#_#_#_#_#_#_#_#_#__######__
483 A _________________#_#_#_#_#_#_#_#_#_#_#_#_#######__
517 A _________________#_#_#_#_#_#_#_#_#_#__#_#_#_#_#_##
519 A _________________#_#_#_#_#_#_#_#_#_#__#_#_#_#_####
521 A _________________#_#_#_#_#_#_#_#_#_#__#_#_#_######
523 A _________________#_#_#_#_#_#_#_#_#_#__#_#_########
525 A _________________#_#_#_#_#_#_#_#_#_#__#_##########
527 A _________________#_#_#_#_#_#_#_#_#_#__############
529 A _________________#_#_#_#_#_#_#_#_#_#_#############
{% endhighlight %}

So basically this thing sweeps out **triangles of increasing width**, and every few triangles it resets. It goes through that cycle a few times, increasing the widest triangle width each time, and then at some point it **quasihalts**. The machine keeps running, but after 2819 steps the tape is never modified again. At that time there is a solid blocks of 69 marks on the tape.

**Why does the program quasihalt, and why does it quasihalt when it does?** I have no idea. I don't understand how the program works. That it should quasihalt at all is in some sense not surprising. After all, if this program didn't quasihalt, I wouldn't have found it, and we wouldn't be talking about it. But as usual, this kind of **anthropic reasoning** fails to provide any real insight.

The program itself is obscure **[spaghetti code](https://nickdrozd.github.io/2021/01/26/spaghetti-code-conjecture.html)**, so the algorithm getting executed to produce this sequence has to be reverse-engineered by observation of the tape evolution. I will spare you the boring details and cut to the chase. You know how they say that **if something seems too good to be true, it probably is**? Well, that turns out to be the case here: it seemed too good to be true that this little program could understand prime numbers, and indeed it does not. The whole thing is a **wild coincidence**.

Here's what's really going on. Consider the values of the sequence greater that are than nine:

{% highlight nil %}
15, 27, 45, 69
{% endhighlight %}

Subtract nine:

{% highlight nil %}
6, 18, 36, 60
{% endhighlight %}

Divide by six:

{% highlight nil %}
1,  3,  6, 10
{% endhighlight %}

Do you recognize this sequence? It is none other than the **[triangular numbers](https://nickdrozd.github.io/2018/08/04/y.html)**:

{% highlight nil %}
 1 = 1
 3 = 1 + 2
 6 = 1 + 2 + 3
10 = 1 + 2 + 3 + 4
{% endhighlight %}

This program, which **manifestly uses a triangle-based method to calculate**, calculates a variation of the triangular numbers. Who could have guessed?

Here are the first eleven entries in the prime pyramid sequence:

{% highlight nil %}
2, 7, 15, 27, 45, 69, 99, 135, 177, 229, 289
{% endhighlight %}

And here are the first eleven entries of the sequence defined by the formula ***3n<sup>2</sup> - 9n + 15***:

{% highlight nil %}
9, 9, 15, 27, 45, 69, 99, 135, 177, 225, 279,
{% endhighlight %}

**For seven consecutive values (namely when *3 ≤ n ≤ 9*), these two sequences are identical.** I don't know why this should be true, but it is. I don't know why this program calculates (just a part of) this sequence, but it does. This fact probably has no importance at all, neither practically nor theoretically. Nevertheless it is **a fact that was discovered from looking at a Busy Beaver program**.
