---
title: "A Tetrational Self-Cleaning Turing Machine"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2026-09-01 Tue&gt;</span></span>
layout: post
categories: 
tags: 
---

Here's a fun one. I found a **3-state 3-color Turing machine program** that, when started on the blank tape, runs for more than **10 ↑↑ 6 steps** before wiping the tape clean. Behold:<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>

![img](/assets/tetrational-self-cleaning-turing-machine/parson-weems-turing-machine.png)

**How many steps exactly does it run?** Well, that is not so easy to say. What happens is that eventually it reaches this machine configuration:

{% highlight nil %}
B2 | ..0 [2] 2^R 0..
{% endhighlight %}

That is, the machine is in state `B`, the only marks on the tape are a solid `2`-block of length *1 + R*, and the machine is scanning the leftmost `2` of that block. The program has the instruction `B2 -> 0RB`, so it remains in state `B` and proceeds to erase every `2` (i.e. overwrite with `0`) as it moves to the right. Once the last `2` is erased, **the tape is blank**. The exact length of *R* is:

{% highlight nil %}
((-27 + (23 * (3 ** ((-13 + (23 * (3 ** ((-15 + (23 * (3 ** ((-21 + (23 * (3 ** ((-13 + (23 * (3 ** 6285))) // 8)))) // 8)))) // 8)))) // 8)))) // 4)
{% endhighlight %}

That's a **valid Python expression**, but don't try to evaluate it. Your interpreter might crash. However, it is possible to get a sense of how large the number is by counting the **nested exponentials**. In fact the exponents are five levels deep, making this a **[tetrational](https://nickdrozd.github.io/2023/09/25/tetration.html)** expression, with a value of "around" 10 ↑↑ 6. This is enough to make it the new **Blanking Beaver champion**! The Blanking Beaver game is just like the classic [Busy Beaver game](https://wiki.bbchallenge.org/wiki/Main_Page), except that instead of running to halt, a Turing machine is run until it erases the tape. The [previous **BLB(3, 3)** champ](https://wiki.bbchallenge.org/wiki/1RB2RB1LA_2LC0LB2LB_2RC2RA0LC) runs for "only" exponentially many steps (around 10<sup>42745</sup> steps).

After erasing the last `2`, the machine scans a `0`, still in state `B`. The program has `B0 -> 0RC`, so it leaves the cell blank, moves right, and goes to state `C`. The tape is still blank, and the program has `C0 -> 2LC`, so the machine will **get stuck** executing that `C0` instruction forever. That is to say, right after erasing the tape, the machine **[quasihalts](https://nickdrozd.github.io/2021/01/14/halt-quasihalt-recur.html)**. Therefore, this program is also a candidate for the **Beeping Busy Beaver game**! Here again, the Beeping Busy Beaver game is just like the classic Busy Beaver game, except that instead of running to halt, a Turing machine is run until it quasihalts.

Regular readers of this blog (???) will recall that I previously reported that **[BBB(3, 3) > 10 ↑↑ 6](https://nickdrozd.github.io/2025/03/24/bbb-3-3.html)**. That is, the [current BBB(3, 3) champ](https://wiki.bbchallenge.org/wiki/1RB0LB2LA_1LA0RC0LB_2RC2RB0LC) quasihalts after 10 ↑↑ 6 steps. Well, here we have a new program that quasihalts after 10 ↑↑ 6 steps. **So, do we have a new champ? Is it a tie? Or what?**

You may have noticed earlier that I said a value was "around" 10 ↑↑ 6, with "around" in "scare quotes". This is because **tetrational estimation is incredibly coarse**. 10 ↑↑ 6 and 10 ↑↑ 7 seem like they ought to be close-ish, because 6 and 7 are close. But 10 ↑↑ 7 is exponentially greater than 10 ↑↑ 6, so not all 10 ↑↑ 6 estimates are created equal.

We saw the expression *R* earlier. The current BBB(3, 3) champ produces a block of marks of length *Q*, where *Q* is:

{% highlight nil %}
2 ** (4 + (2 ** (4 + (2 ** (4 + (2 ** (4 + (2 ** (4 + (2 ** 20))))))))))
{% endhighlight %}

**Which of *Q* and *R* is greater?** Not obvious at first glance, but again a good clue is the nestedness of the exponentials. *R* has exponents nested five deep, while *Q* is nested six deep. This at least preliminarily suggests that *Q* is greater. And indeed, applying Shawn Ligocki's **[extended up-arrow notation](https://www.sligocki.com/2022/06/25/ext-up-notation.html)** leads to finer estimates:

-   *R* ≅ 10 ↑↑ 6.54
-   *Q* ≅ 10 ↑↑ 6.74

**So this new program is the new BLB(3, 3) champ, but it is not the new BBB(3, 3) champ.**


# Exercises for the reader

1.  Give a proper analysis of the new program.
2.  Determine the exact quasihalt step counts of the current BBB(3, 3) champ and the new candidate.
3.  Exhibit nice-looking LaTeX for *Q* and *R*.
4.  Come up with a new champ for BLB(3, 3), or else prove that this is the true champ.
5.  This post addresses the question of step counts, but it mostly discusses mark counts. Why is that?


# Related

-   [A New Record in Self-Cleaning Turing Machines](https://nickdrozd.github.io/2021/07/11/self-cleaning-turing-machine.html) (2021)
-   [Another New Record in Self-Cleaning Turing Machines](https://nickdrozd.github.io/2022/01/10/another-self-cleaning-turing-machine.html) (2022)

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> In plain text:

{% highlight nil %}
    +-----+-----+-----+
    |  0  |  1  |  2  |
+---+-----+-----+-----+
| A | 1RB | 1RC | 2RA |
+---+-----+-----+-----+
| B | 0RC | 2RA | 0RB |
+---+-----+-----+-----+
| C | 2LC | 2LB | 0LA |
+---+-----+-----+-----+
{% endhighlight %}
