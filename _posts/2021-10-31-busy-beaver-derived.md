---
title: "A Busy Beaver Champion Program Derived from Scratch"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-10-31 Sun&gt;</span></span>
layout: post
categories:
tags:
---
The **classic Busy Beaver game** asks how long an *n*-state *k*-color Turing machine program can run before **executing a halt instruction**. The phrase "executing a halt instruction" is not normally used in stating the problem; instead, people just say "halting". But executing a halt instruction is just one way for a program to signal that it is finished. From the point of view of a programmer trying to maximize machine steps, it's about **the worst termination signal possible** because it requires wasting valuable program space on the halt instruction. If **[other termination conditions](https://nickdrozd.github.io/2021/01/14/halt-quasihalt-recur.html)** are allowed, programs can run for much, much longer.

[I recently discovered one such program.](https://nickdrozd.github.io/2021/07/11/self-cleaning-turing-machine.html) With just four states and two colors, it undertakes a computation for **32,779,478 steps** before signalling termination. (Don't worry, we'll get to how exactly this "termination" is "signalled".) Among programs with an explicit halt instruction the record is 107 steps, so this new champion is a shocking improvement. **A slightly more liberal understanding of program behavior vastly increases expressive power.**

You might think that such a program would be complicated and difficult to understand. This, at least, is what the **[Spaghetti Code Conjecture](https://nickdrozd.github.io/2021/01/26/spaghetti-code-conjecture.html)** predicts. In fact, [the Spaghetti Code Conjecture might be false](https://nickdrozd.github.io/2021/09/25/spaghetti-code-conjecture-false.html), and **the program is remarkably elegant**. It's so straightforward that it can be **derived from scratch**.


# Table of Contents

1.  [Number Theory](#org83935fc)
2.  [C implementation of *L*](#orgff4cd9e)
3.  [Getting the input onto the tape](#org6b733fa)
4.  [From C to Turing Machine](#org3caefc6)
5.  [Structured Programming](#orge8ed5cd)
6.  [Who wrote this program?](#org8af05bf)
7.  [Turing machine programming exercise](#org79c139f)


<a id="org83935fc"></a>

# Number Theory

First, a little **number theory**. Consider the following function:

{% highlight nil %}
L : ℕ -> ℕ
L (3k)     = 0
L (3k + r) = L (5k + r + 3)
{% endhighlight %}

Here's a description in plain language. *L* checks if its input is divisible by 3. If it is, the output is 0; otherwise, some transformation is applied to the input and *L* is called again, recursively, on the result. **Is *L* total?** That is, does it return an answer for all inputs? That's an **open question**.

Here's another function with a similar flavor:

{% highlight nil %}
C : ℕ -> ℕ
C 0        = 0
C 1        = 1
C (2k)     = C k
C (2k + 1) = C (3k + 2)
{% endhighlight %}

Is *C* total? The **Collatz Conjecture** says that it is, but that too is an open question. But forget about *C*. We're interested in *L*.

It usually takes no more than a few iterations to caluclate *L(n)*, but occasionally it takes longer. In particular, it is strange but true that ***L(2)* requires fourteen iterations to calculate**. Keep this fact in mind for later.


<a id="orgff4cd9e"></a>

# C implementation of *L*

We're going to write **a Turing machine program that implements *L***.

No, wait, actually we *won't* write a Turing machine program. [My last post](https://nickdrozd.github.io/2021/09/25/spaghetti-code-conjecture-false.html) got submitted to a few discussion boards under the topic of "programming". **Several commenters complained** that it was not about programming at all, but rather theoretical computer science, and that it didn't have any code in it, and that it wasn't practical. So instead of writing "theoretical" Turing machine code, we'll implement *L* in an eminently practical language, namely **C**. Who would *dare* question the real-world usefulness of C? What better language is there for "real programmers" to "get things done"?

So, **the goal is to write a C program that implements *L***. But not just any program; we need a program written pursuant to some **unusual and severe constraints**. First, there will be just one header included:

{% highlight c %}
#include "machine.h"
{% endhighlight %}

This file defines a `short` array, which we'll refer to as the *tape*. Every cell of the tape is initialized to `0` unless otherwise specified. The exact length of the tape is unknown, but it is plenty long for our purposes. **There is no need to worry about checking any bounds.**

There is also a pointer into the tape array, but we won't have direct access to it. Instead, the header provides four **tape-manipulation macros**:

-   `PRINT`: writes a `1` to the current cell;
-   `ERASE`: writes a `0` to the current cell;
-   `RIGHT`: moves the tape pointer one cell to the right; and
-   `LEFT`: moves the tape pointer one cell to the left.

A fifth macro, `BLANK`, returns whether the current cell contains a `0`. It doesn't execute any side effects.

Those are the **primitive operations** to which we have access. Beyond that, our `main` function will have a specific form:

-   There will be **exactly four labels**.
-   Under each label will be an `if` / `else` block with `(BLANK)` as the test condition.
-   The body of each branch will contain three statements:
    1.  either `PRINT;` or `ERASE;`, and
    2.  either `LEFT;` or `RIGHT;`, and
    3.  a jump to one of the four labels (i.e. a statement of the form `goto <LABEL>;`)

Note that if the current cell if `0` and `ERASE` is executed, nothing will happen, and similar for `PRINT` on `1`. So the print / erase statements can be regarded as optional.

We're trying to implement *L*, which means a program that will calculate *L(n)* given an input *n*. The input *n* will be represented as a block of *n* consecutive marks (`1`'s) on the tape, with all other cells blank (`0`). **How exactly these marks get onto the tape will be left unspecified for now**, but we'll return to this point later. The initial position of the tape pointer will be at the first blank cell directly to the right of the block of marks. We call this the ***initial configuration***<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>. Here is what the initial position looks like when the input is 13 (where `^` indicates the current position of the tape pointer and `*` indicates the starting cell of the tape pointer):

{% highlight nil %}
                  *
...__1111111111111___...
                  ^
{% endhighlight %}

Let's take another look at the definition of *L*:

{% highlight nil %}
L : ℕ -> ℕ
L (3k)     = 0
L (3k + r) = L (5k + r + 3)
{% endhighlight %}

With a full range of standard math operations available, this would be easy. Divide *n* by 3 to get *k*, then multiply *k* by 5 and add the rest of the terms. That would be nice, wouldn't it? But the available operations are **too low-level** for that; in this setting, division and multiplication are quite sophisticated.

Remember that *n* is represented in **unary notation**, and our operations are limited to shuffling around tally marks. The **fundamental algorithm** will be based around this idea: subtract 3 from *n*, then add 2 marks outside the initial block, then fill in the 3 that were subtracted. This procedure will then be iterated in the style of **[Shlemiel the Painter](https://www.joelonsoftware.com/2001/12/11/back-to-basics/)** to count through every group of 3 marks in *n*. The remainder will be left alone, and a few extra marks will be added along the way to demarcate the working areas of the tape. The end result will be that where there were previously *3k + r* marks, now there are *5k + r + 3*.

When the program starts, control is at the first label and the current cell (according to the stipulated intial configuration) is blank. The first move will be to set down what we'll call the *post*. **The post demarcates the right edge of the initial block.** Then we move left and continue on until we find the start of the block, which at this point will be just one cell away. Later on, however, it will be further.

Once we get to the start of the block, control is still with the initial label. As per the fundamental algorithm, we need to **count exactly three marks**. By virtue of having found the block, the tape pointer is already on the first mark, so that's one. We need to count two more. Leave the current mark alone, then move left and transfer to the next label.

So far, the program looks like this:

{% highlight c %}
main() {
 POST_AND_FIND:
  if (BLANK)
    {
      // Set down the post at the edge of the block.
      PRINT;
      LEFT;
      goto POST_AND_FIND;
    }
  else
    {
      // Found the first mark to count; move to the next.
      LEFT;
      goto COUNT_SECOND_MARK;
    }

 COUNT_SECOND_MARK:
  // ???
}
{% endhighlight %}

And the tape looks like this:

{% highlight nil %}
                  *
...__11111111111111__...
                 ^
{% endhighlight %}

Once again, we leave the mark alone, move left, and transfer to the next label.

{% highlight c %}
main() {
 POST_AND_FIND:
  // ...

 COUNT_SECOND_MARK:
  if (BLANK)
    {
      // ???
    }
  else
    {
      // Found the second mark; keep going.
      LEFT;
      goto COUNT_THIRD_MARK;
    }

 COUNT_THIRD_MARK:
  // ???
}
{% endhighlight %}

Now the tape pointer is at the third mark from the right of the initial block:

{% highlight nil %}
                  *
...__11111111111111__...
               ^
{% endhighlight %}

The fundamental algorithm says to subtract 3 and then add 2 and then add the 3 back. So we'll erase all the marks we just counted. In fact, we'll wipe everything until we find the edge of the block, including the post:

{% highlight c %}
main() {
 POST_AND_FIND:
  // ...

 COUNT_SECOND_MARK:
  // ...

 COUNT_THIRD_MARK:
  if (BLANK)
    {
      // ???
    }
  else
    {
      // Found the third mark;
      // wipe everything and move back to the edge.
      ERASE;
      RIGHT;
      goto COUNT_THIRD_MARK;
    }
}
{% endhighlight %}

Control will remain with this label for a few steps. Eventualy the tape pointer will reach a blank cell, namely the cell directly to the right of the initial square. We leave the cell blank, then move right one more square, then transfer control back to the starting label, `POST_AND_FIND`.

{% highlight nil %}
                  *
...__1111111111________...
                    ^
{% endhighlight %}

The current cell is two to the left of the initial square. Three marks have been erased from the starting input block, as per the fundamental algorithm. `POST_AND_FIND` will now set down a new post and find what's left of the block, filling in all the blank squares along the way.

{% highlight nil %}
                  *
...__1111111111111111__...
              ^
{% endhighlight %}

This process will go through a few more iterations, each time moving three marks further into the initial block and two spaces further to the right of the starting square. **This is how *3k* is transformed into *5k*.**

Here is the program so far:

{% highlight c %}
main() {
 POST_AND_FIND:
  if (BLANK)
    {
      // Set down the post at the edge of the block.
      PRINT;
      LEFT;
      goto POST_AND_FIND;
    }
  else
    {
      // Found the first mark to count; move to the next.
      LEFT;
      goto COUNT_SECOND_MARK;
    }

 COUNT_SECOND_MARK:
  if (BLANK)
    {
      // ???
    }
  else
    {
      // Found the second mark; keep going.
      LEFT;
      goto COUNT_THIRD_MARK;
    }

 COUNT_THIRD_MARK:
  if (BLANK)
    {
      // Found the edge of the block;
      // go back to the top.
      RIGHT;
      goto POST_AND_FIND;
    }
  else
    {
      // Found the third mark;
      // wipe everything and move back to the edge.
      ERASE;
      RIGHT;
      goto COUNT_THIRD_MARK;
    }
}
{% endhighlight %}

On the program side, the blank instruction for `COUNT_SECOND_MARK` hasn't been used, and the fourth label hasn't yet been mentioned. On the math side, we still don't know how to handle the remainder, if there is one, or how to end the computation if there isn't. Eventually the tape will look like this:

{% highlight nil %}
               *
__1_______________________
                       ^
{% endhighlight %}

There is just one mark left, representing the remainder of thirteen when divided by three. Control is with `POST_AND_FIND`, which fills in the blanks and transfers control to `COUNT_SECOND_MARK`:

{% highlight nil %}
                *
___######################__
  ^
{% endhighlight %}

The remainder has been found, which means **every group of three has been extended by two**. We print a mark and transfer to the fourth and final label, `FINALIZE`. This label will just move back across the block of marks until it finds a blank, at which point it will print, move right, and transfer control to the starting label:

{% highlight c %}
main() {
 POST_AND_FIND:
  // ...

 COUNT_SECOND_MARK:
  if (BLANK)
    {
      // Found the remainder; finalize.
      PRINT;
      RIGHT;
      goto FINALIZE;
    }
  else
    {
      // Found the second mark; keep going.
      LEFT;
      goto COUNT_THIRD_MARK;
    }

 COUNT_THIRD_MARK:
  // ...

 FINALIZE:
  if (BLANK)
    {
      // Found the edge of the block;
      // on to the next iteration!
      PRINT;
      RIGHT;
      goto POST_AND_FIND;
    }
  else
    {
      // Somewhere in the block; keep going.
      RIGHT;
      goto FINALIZE;
    }
}
{% endhighlight %}

To review: two marks were added for each group of three marks; the remainder was left alone; and the post in the middle plus a mark on either end of the block makes three. ***3k + r* is transformed into *5k + r + 3*, and the program is once again in the initial coniguration, ready for another iteration.**

So far we've handled the case where there is a remainder of one. What about when there is a remainder of two? `POST_AND_FIND` counts the first mark, then `COUNT_SECOND_MARK` counts the second, and then control goes to `COUNT_THIRD_MARK` on a blank cell. Well, we've already developed a **remainder-handling subroutine**, so why not reuse that? Leave the cell blank, move right, then go back to `POST_AND_FIND`. **One case is reduced to the other.**

At last we have the **glorious final version of the program**:

{% highlight c %}
main() {
 POST_AND_FIND:
  if (BLANK)
    {
      // Set down the post at the edge of the block.
      PRINT;
      LEFT;
      goto POST_AND_FIND;
    }
  else
    {
      // Found the first mark to count; move to the next.
      LEFT;
      goto COUNT_SECOND_MARK;
    }

 COUNT_SECOND_MARK:
  if (BLANK)
    {
      // Found the remainder; finalize.
      PRINT;
      RIGHT;
      goto FINALIZE;
    }
  else
    {
      // Found the second mark; keep going.
      LEFT;
      goto COUNT_THIRD_MARK;
    }

 COUNT_THIRD_MARK:
  if (BLANK)
    {
      // Found a remainder of two;
      // go back and treat it like a remainder of one;
      RIGHT;
      goto POST_AND_FIND;
    }
  else
    {
      // Found the third mark;
      // wipe everything and move back to the edge.
      ERASE;
      RIGHT;
      goto COUNT_THIRD_MARK;
    }

 FINALIZE:
  if (BLANK)
    {
      // Found the edge of the block;
      // on to the next iteration!
      PRINT;
      RIGHT;
      goto POST_AND_FIND;
    }
  else
    {
      // Somewhere in the block; keep going.
      RIGHT;
      goto FINALIZE;
    }
}
{% endhighlight %}

What happens when there is no remainder? According to the definition of *L*, the output should be zero. There's no more program left to write, so hopefully that's what happens! After the third mark is counted, `COUNT_THIRD_MARK` wipes everything to the right. But by hypothesis, there is nothing else to the left, since the third mark was the very last one. So every remaining mark on the tape will get wiped, and then control gets passed back to `POST_AND_FIND`.

When that label executes and the tape is totally blank (that is, there is an input of 0), there is no block to find, so it will start printing marks and moving to the left **forever**. But observe that this behavior is both **obviously degenerate** and **easily detectable**. Therefore we can plausibly regard this simple instance of **[Lin recurrence](https://nickdrozd.github.io/2021/02/24/lin-recurrence-and-lins-algorithm.html)** as the program's means of **signalling termination**.


<a id="org6b733fa"></a>

# Getting the input onto the tape

So, we have a program that will calculate *L(n)* given an initial input of *n*, and we know that *L(2)* runs for a long time. But the rules of the Busy Beaver game say that the tape must start off blank. **How does the initial input get onto the tape?**

This is a question in the field of Turing machines that is **terribly under-discussed**. Great efforts are made to find the "simplest possible machine" to do this or that, but the measure of "simplicity" never seems to include the tape inputs. How much computation is required to get the input onto the tape? Is the "simple machine" doing the computation, or is it really just consuming pre-digested mush? **What is the true complexity of the total end-to-end computational process?**

From the Busy Beaver perspective, getting an input for free is **cheating**. The blank tape initial condition provides a level playing field by providing nothing whatsoever in advance. Every program has to prepare its own input, and in this way **the total complexity is accurately measured**.

As it happens, **one simple tweak** will suffice to prepare the required input. Simply rearrange the labels so that program execution begins with `COUNT_SECOND_MARK` instead of `POST_AND_FIND`:

{% highlight c %}
main() {
 COUNT_SECOND_MARK:
  if (BLANK)
    { PRINT; RIGHT; goto FINALIZE; }
  else
    {/* ... */}

 FINALIZE:
  if (BLANK)
    { PRINT; RIGHT; goto POST_AND_FIND; }
  else
    {/* ... */}

 COUNT_THIRD_MARK:
  // ...

 POST_AND_FIND:
  // ...
}
{% endhighlight %}

With this, the first few steps of the program on the blank tape are:

{% highlight nil %}
PRINT;
RIGHT;
goto FINALIZE;
PRINT;
RIGHT;
goto POST_AND_FIND;
{% endhighlight %}

**Now there are two marks on the tape and the program is in the initial configuration, ready to rock.** The long computation is executed and a high score is achieved.


<a id="org3caefc6"></a>

# From C to Turing Machine

If you're still reading this, you've probably guessed that the bizarre constraints placed on the C program are based on the **logical structure of Turing machine programs**. When we say that a Turing machine has *n* "states", this corresponds to a C program with *n* labels. **"State" is a crappy name, and we should really talk about "labels" instead**. The "colors" or "symbols" of a Turing machine correspond to the numbers that can go into the cells of the tape array.

Renaming the labels of the C program to single letters, we get the code for the champion Turing machine:

{% highlight nil %}
    +-----+-----+
    |  0  |  1  |
+---+-----+-----+
| A | 1RB | 1LC |
+---+-----+-----+
| B | 1RD | 1RB |
+---+-----+-----+
| C | 0RD | 0RC |
+---+-----+-----+
| D | 1LD | 1LA |
+---+-----+-----+
{% endhighlight %}

Or, in [string notation](https://nickdrozd.github.io/2020/10/04/turing-machine-notation-and-normal-form.html):

{% highlight nil %}
1RB 1LC  1RD 1RB  0RD 0RC  1LD 1LA
{% endhighlight %}


<a id="orge8ed5cd"></a>

# Structured Programming

We've seen how the champion program works, but the **control flow** is not exactly obvious from the `goto`-ridden code. Clarity can be improved by introducing standard **[structured programming](https://nickdrozd.github.io/2021/04/21/structured-programming-for-busy-beavers.html)** operators. For example, consider the `COUNT_THIRD_MARK` label:

{% highlight c %}
COUNT_THIRD_MARK:
 if (BLANK)
   {
     RIGHT;
     goto POST_AND_FIND;
   }
 else
   {
     ERASE;
     RIGHT;
     goto COUNT_THIRD_MARK;
   }
{% endhighlight %}

This is equivalent to a `while` loop:

{% highlight c %}
while (!BLANK) {
  ERASE;
  RIGHT;
}

RIGHT;
goto POST_AND_FIND;
{% endhighlight %}

Using this and a few other basic transformation techniques, the program can be transformed into **fully well-structured code**:

{% highlight c %}
int main(void)
{
  while (1) {
    if (BLANK)
      {
        PRINT;

        do {
          RIGHT;
        } while (!BLANK);

        PRINT;
      }
    else
      {
        LEFT;

        while (!BLANK) {
          ERASE;
          RIGHT;
        }
      }

    RIGHT;

    while (BLANK) {
      PRINT;
      LEFT;
    }

    LEFT;
  }
}
{% endhighlight %}

Observe that there are **no `break` or `continue` statements**, and there is **just one branch point**. There is even a `do-while` loop.


<a id="org8af05bf"></a>

# Who wrote this program?

I hope that you are convinced by now that this program is not some kind of inscrutable tangle of spaghetti code. There are **subroutines** that execute particular actions as if in the service of a **plan** of some kind. **It could have been written by somebody.**

And yet, it wasn't. **Nobody wrote it.** It was just floating out there in the full space of 4-state 2-color Turing machine programs, and I managed to find it. **I did not write it.** I woke up one morning and found it on my screen. I didn't have a clue what it did until **[Shawn Ligocki reverse engineered it](https://www.sligocki.com/2021/07/17/bb-collatz.html)**. He determined that the program's behavior could be described by the function *L*, and from there I was able to work out the fine details of the program's instructions.


<a id="org79c139f"></a>

# Turing machine programming exercise

The following exercise is due to **[Bruce Smith](https://scottaaronson.blog/?p=5661#comment-1900320)**.

The program described here starts on the blank tape and then the tape is blank again after 32,779,477.

**Add one label to the program so that it reaches the blank tape after 32,810,047 steps.**

Hint: take advantange of the `do-while` loop.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> This initial configuration differs slightly from what some authors refer to as the *standard configuration*. But that "standard" is just a made-up convention, so who cares?
