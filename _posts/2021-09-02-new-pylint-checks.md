---
title: "Exciting New Ways To Be Told That Your Python Code is Bad"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-09-02 Thu&gt;</span></span>
layout: post
categories:
tags:
---
**I love linters.** A linter is a program that looks for problems in code without running it. There is something gratifying about running a linter on a codebase and seeing a big list of warnings and errors. Sometimes it can even be fun to fix them!

**A lot of programmers hate linters**, and they will look for any reason to ignore them. They will say things like "There are too many false positives!" and "There are too many false negatives!" and other excuses. But fundamentally the problem is that programmers don't like to have their code criticized and they don't like to be told what to do.

Well, **tough shit**, because I [recently](https://github.com/PyCQA/pylint/pull/4860) [added](https://github.com/PyCQA/pylint/pull/4871) two *highly opinionated* checkers to the Python linter **Pylint**. These checkers are so opinionated that they are not turned on by default &#x2013; they are extensions that have to be enabled manually.

-   **`consider-ternary-expression`**

Consider the following code block:

{% highlight python %}
if condition():
    x = 4
else:
    x = 5
{% endhighlight %}

What does the block do? Apparently it assigns one or another value to the variable `x` depending on the value of `condition()`. That's the natural language description of the block, and it's just one statement. But the code itself is more complicated than just one statement: it's an `if`-statement with one assign statement in each of its sub-blocks.

Generally speaking, **less code is better than more code**, and this block can be rewritten more concicely as follows:

{% highlight python %}
x = 4 if condition() else 5
{% endhighlight %}

**Just one statement!** No muss, no fuss. Well, actually there would be a great deal of fuss if this check were enabled by default. Python programmers in general have an irrational aversion to if-expressions, a.k.a. the "ternary" operator. Lisp uses if-expressions, and everything is fine:

{% highlight emacs-lisp %}
(setq x (if (condition) 4 5))
{% endhighlight %}

Anyway, this is **just a style thing**. It doesn't affect program correctness or structure in a meaningful way. The check only triggers in the specific circumstance given in the example. It won't trigger, for instance, if there is an if-elif-else block, or if there are nested if-statements.

-   **`while-used`**

This next check is more radical: **it unconditionally flags every use of `while` expressions**.

*"My god,"* I hear you say. *"Not good old `while` loops! How can I be expected to write any code without using `while`? What's next? No `if`? No `def`? What an absurd and pointless restriction!"*

This is the kind of **chicken-little** reaction I mentioned earlier.

But here's the reality: **most code is not complex enough to warrant `while` loops, and most `while` loops are better written as `for` loops**. That's the fact of the matter, and you need to come to grips with it.

This is not the case for *every single* `while` loop, but it is true for most of them. Here are a few **exceptions**:

-   the tippety-toplevel application driver;
-   anything that runs for as long as the user says it should run;
-   theorem provers and programming language interpreters;
-   ???

A `while` loop introduces **unbounded computation**. Do you really need unbounded computation for your boring web app? I doubt it. In almost all cases, the loop can be bounded in advance, as in "do this N times" or "do this for every item in this list". Those kinds of loops are **guaranteed to terminate**, and that's a nice guarantee to have.

If you have a `while` loop and you are not working on something that requires unbounded computation, chances are that it can be rewritten more clearly as a `for` loop. **I ran this check against the Pylint codebase itself**, and I was shocked by the hideousness of some of the `while`'s that turned up. They couldn't all be rewritten, but many could.

Even the recently-discovered **[Beeping Busy Beaver champion program](https://nickdrozd.github.io/2021/07/11/self-cleaning-turing-machine.html)** only uses one unbounded `while` loop, and that's as a kind of toplevel program driver.

You know what else doesn't have unbounded loops? **Excel**. All that *money stuff* that gets done with Excel is done with bounded loops.

Ultimately, most code deals with functions that are **primitive recursive**, and for those applications `while` could be banished from the language entirely. Genuinely unbounded loops are required for **general recursive** and **uncomputable** functions, and workaday programmers and scientists don't deal with those kinds of things.
