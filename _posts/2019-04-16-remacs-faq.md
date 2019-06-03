---
title: "Remacs FAQ"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2019-04-16 Tue&gt;</span></span>
layout: post
categories:
tags:
---
**[Remacs](https://github.com/remacs/remacs)** is a **fork** of **Emacs** that aims to reimplement the Emacs core. Although most Emacs code is written in a dialect of **Lisp**, the interpreter for that Lisp (along with low-level stuff like IO) is written in **C**. The goal of Remacs is to **rewrite the C code in Rust** while maintaining **"bug-for-bug compatibility"** with Emacs.

Certain recurring questions seem to come up whenever Remacs is discussed, so here is a handy **FAQ** to address them. (**Disclaimer**: I've made nonnegligible contributions to Remacs. The opinions contained in this FAQ are not necesssarily those of the Remacs project or any of its contributors, including me.)


# Table of Contents

1.  [Rewriting interpreted Elisp in compiled Rust is a bad idea.](#orgf44f708)
2.  [What do I need to do to make my **config** work with Remacs?](#org0de364a)
3.  [What are the **end-user benefits** of switching from Emacs to Remacs?](#org11dae9d)
4.  [So there are **no new features**?](#org1fbbab5)
5.  [That sounds like a lot of work for nothing. **What's the point?**](#orgccf425b)
6.  [Rewrites are a bad idea. **This will never work.**](#orgc67e024)
7.  [What **version of Rust** does Remacs use?](#orge33d878)
8.  [When will the port be finished?](#orgb137719)
9.  [Will Remacs **replace** Emacs?](#org8964551)
10. [Rust is a language for **hipsters**. What's wrong with good old-fashioned C, like Mom used to make?](#orgf1b28b9)
11. [Will Remacs include **Guile** integration?](#org629e330)
12. [What if Remacs causes a **schism** among Emacs users? Nobody wants another **XEmacs**.](#orgdb9c715)
13. [This will drain mindshare and effort from core Emacs development.](#orgc7732fe)
14. [To what extent do the Rust implementations of Lisp functions match their C counterparts?](#org3e041b7)
15. [What are `DEFUN` and `lisp_fn`?](#orga2b5a3e)
16. [It would be better to work on **improving Elisp** itself instead of messing with the underlying implementation.](#org4b4966e)
17. [It would better to **replace Elisp** with [Common Lisp / Scheme / Python / other].](#org990b404)
18. [Will this fix Emacs's long-standing **long-lines problem**?](#org46c3fc9)
19. [Will the Rust code get **upstreamed**?](#orgd3f3e12)
20. [You're using the word *port* wrong. It means extending existing code to a new platform, not rewriting code in a new language.](#orgd5d57ff)
21. [**How can I contribute?**](#orgf13ede3)
22. [Strawberries don't grow on trees.](#org80252d9)
23. [How many Remacs contributors are there?](#org63f5da5)
24. [Where has Remacs been discussed?](#orgf014e6c)
25. [Where has this FAQ been discussed?](#orga947ef6)


<a id="orgf44f708"></a>

# Rewriting interpreted Elisp in compiled Rust is a bad idea.

No, you've misunderstood. The underlying C code is being rewritten, and the goal is to **leave the Elisp undisturbed**.


<a id="org0de364a"></a>

# What do I need to do to make my **config** work with Remacs?

Nothing, ideally. Remacs is intended to be a **drop-in replacement** for Emacs. **Any differences in behavior are considered bugs**, and [filing an issue](https://github.com/remacs/remacs/issues) would be appreciated. (Small changes might be required if you have Lisp code that [interacts directly](https://github.com/Wilfred/helpful/pull/164) with the low-level code.)


<a id="org11dae9d"></a>

# What are the **end-user benefits** of switching from Emacs to Remacs?

The main benefit is **the thrill of using cutting-edge technology**.


<a id="org1fbbab5"></a>

# So there are **no new features**?

That's right. There has been vague talk of doing something with **concurrency** or **multithreading** in the future, as well as speculation that Remacs might end up with **speed improvements** in areas like **JSON parsing**, but **nothing concrete has come**.


<a id="orgccf425b"></a>

# That sounds like a lot of work for nothing. **What's the point?**

I don't know that the Remacs developers have a common motivation, but I would guess that most of them are in it for at least one of the following:

1.  **Exploring Emacs internals**
2.  **Playing with Rust**

Personally I'm more interested in 1 than 2, but I've certainly come to a better understanding of some Rust concepts along the way (I still don't get lifetimes or iterators though).

That's the point from the individual contributor perspective. From the point of view of Emacs itself, work on Remacs led to **the discovery of at least two bugs**, one in the [interpreter](https://debbugs.gnu.org/cgi/bugreport.cgi?bug=25684) and one in the [test suite](https://debbugs.gnu.org/cgi/bugreport.cgi?bug=25534). Remacs has also developed [a large test suite of its own](https://github.com/remacs/remacs/tree/master/test/rust_src/src), mostly smoke tests for low-level functions. These could potentially be contributed upstream. I mean, I don't know if anyone needs tests for [`memory-use-count`](https://github.com/remacs/remacs/blob/918f133602e911b618fe2568c041a9cdb4f306e6/test/rust_src/src/alloc-tests.el#L5), but why not?.


<a id="orgc67e024"></a>

# Rewrites are a bad idea. **This will never work.**

The rewrite is **incremental**, so in a sense it already works. Rust and C are able to talk to each other, so much of the code can be ported function by function, with the editor remaining fully functional the whole time (modulo bugs).


<a id="orge33d878"></a>

# What **version of Rust** does Remacs use?

According to one of the lead maintainers, Remacs ["leans HEAVILY into **nightly**"](https://github.com/remacs/remacs/pull/1153#issuecomment-448675225).


<a id="orgb137719"></a>

# When will the port be finished?

A meaningful estimate is not possible at this point. Personally I'm skeptical that it will ever be completely finished. Will anyone port [the garbarge collector](https://github.com/remacs/remacs/blob/918f133602e911b618fe2568c041a9cdb4f306e6/src/alloc.c#L5753)? Or [the bytecode interpreter](https://github.com/remacs/remacs/blob/918f133602e911b618fe2568c041a9cdb4f306e6/src/bytecode.c#L320)? Maybe, but progress might stall out before anyone figures out **the hairy stuff**.


<a id="org8964551"></a>

# Will Remacs **replace** Emacs?

**No**. I don't know of anyone, including the Remacs developers, who has switched completely from using Emacs to using Remacs, and I don't see that changing.


<a id="orgf1b28b9"></a>

# Rust is a language for **hipsters**. What's wrong with good old-fashioned C, like Mom used to make?

Don't ask me, I just work here.


<a id="org629e330"></a>

# Will Remacs include **Guile** integration?

[ **Guile Emacs** ](https://lwn.net/Articles/615220/) is an attempt to replace the Emacs interpreter with the [Guile](https://www.gnu.org/software/guile/manual/html_node/index.html) interpreter, which would allow scripting in languages besides Elisp (especially **Scheme**). It's been in the works for a while.

There are no plans to include Guile integration in Remacs. Including an experimental, unfinished interpreter would dramatically increase the **complexity** of the project.


<a id="orgdb9c715"></a>

# What if Remacs causes a **schism** among Emacs users? Nobody wants another **XEmacs**.

[**XEmacs**](https://nickdrozd.github.io/2019/02/19/xemacs.html) was a fork of Emacs with cutting-edge new features, developed commercially by some of the best Lisp hackers in the world. **In contrast**, Remacs is a fork of Emacs with no new features at all, developed for fun by whoever shows up. I think the community is safe.


<a id="orgc7732fe"></a>

# This will drain mindshare and effort from core Emacs development.

On the contrary, working on Remacs is a great **onboarding exercise** for the Emacs codebase. Someone who has successfully ported a handful of low-level Lisp functions from C to Rust is in a position to go on to make changes to the existing C code. I myself recently made a **[small contribution](https://nickdrozd.github.io/2018/12/20/emacs-commit.html)** to core Emacs, and that certainly would not have happened had it not been for Remacs.


<a id="org3e041b7"></a>

# To what extent do the Rust implementations of Lisp functions match their C counterparts?

Most of the ported functions follow their original implementations pretty closely. The most **divergent** one that I know of is `byteorder`, a function of no arguments that *returns 66 (ASCII uppercase B) for big endian machines or 108 (ASCII lowercase l) for small endian machines*:

{% highlight c %}
DEFUN ("byteorder", Fbyteorder, Sbyteorder, 0, 0, 0,
       doc: /* ... */
       attributes: const)
  (void)
{
  unsigned i = 0x04030201;
  int order = *(char *)&i == 1 ? 108 : 66;

  return make_fixnum (order);
}
{% endhighlight %}

{% highlight rust %}
#[lisp_fn]
pub fn byteorder() -> u8 {
    if cfg!(endian = "big") {
        b'B'
    } else {
        b'l'
    }
}
{% endhighlight %}

Which implementation is nicer? You be the judge.


<a id="orga2b5a3e"></a>

# What are `DEFUN` and `lisp_fn`?

[`DEFUN`](https://github.com/remacs/remacs/blob/918f133602e911b618fe2568c041a9cdb4f306e6/src/lisp.h#L3017) and [`lisp_fn`](https://github.com/remacs/remacs/blob/918f133602e911b618fe2568c041a9cdb4f306e6/rust_src/remacs-macros/lib.rs#L18) are macros in C and Rust, respectively, for defining exposed Lisp functions (that is, functions that can be called from within Emacs). `DEFUN` is great, but `lisp_fn` is truly a marvel. Whereas `DEFUN` requires all inputs and outputs to be of the union type `Lisp_Object`, `lisp_fn` allows functions to defined with native Rust types. This gives **greater compile-time guarantees of type-correctness**.


<a id="org4b4966e"></a>

# It would be better to work on **improving Elisp** itself instead of messing with the underlying implementation.

Why not both?


<a id="org990b404"></a>

# It would better to **replace Elisp** with [Common Lisp / Scheme / Python / other].

I don't know, sounds dicey. In any case, that's not related to this project.


<a id="org46c3fc9"></a>

# Will this fix Emacs's long-standing **long-lines problem**?

No. That would require changes to algorithms or architecture, which are **language-independent**. Nothing is free, and deep problems don't just solve themselves because you sprinkled on some Rust; you have to actually figure out a solution. **Rust isn't magic**.


<a id="orgd3f3e12"></a>

# Will the Rust code get **upstreamed**?

For several reasons, I doubt it.

1.  Rewrites always introduce **instability and new bugs**, and so far at least there is nothing to be gained in exchange.
2.  Rust is based on **LLVM**, which is apparently [**not Free**](https://gcc.gnu.org/ml/gcc/2014-01/msg00247.html). I don't really understand the details, but I do tend to trust **Richard Stallman**. If someone comes up with a solid Rust frontend for **GCC**, we can drop this reason.
3.  Remacs doesn't require **copyright assignment** to contribute, and [Emacs does](https://www.gnu.org/software/emacs/manual/html_node/emacs/Copyright-Assignment.html). Upstream won't accept code with murky legal status.

A lot of **tantrums** have been thrown about reasons 2 and 3.


<a id="orgd5d57ff"></a>

# You're using the word *port* wrong. It means extending existing code to a new platform, not rewriting code in a new language.

No, port is a kind of fortified wine.


<a id="orgf13ede3"></a>

# **How can I contribute?**

The easiest thing to do would be to actually **use Remacs** and report any bugs you find. Crashes are bugs, obviously, but so are any deviations from expected Emacs behavior, even small ones.

If you want to contribute code, just find a C `DEFUN` and then port it. The file [`src/window.c`](https://github.com/remacs/remacs/blob/master/src/window.c) has lots of easy ones (that's where I started). From there you can work your way up to progressively harder functions. But hurry, before all the **low-hanging fruit** is gone! There used to be more, like `car-less-than-car`, but I've already picked a lot of those strawberries.


<a id="org80252d9"></a>

# Strawberries don't grow on trees.

Oh. Well anyway, if you're really ambitious, you can try setting up a **[profiler](https://github.com/remacs/remacs/issues/1288)**. Currently we don't know how much is spent on, for example, type conversion, and profiling would give some insight into what's really going on.


<a id="org63f5da5"></a>

# How many Remacs contributors are there?

Remacs forks Emacs, so [the contributor list](https://github.com/remacs/remacs/graphs/contributors) includes anyone who has ever worked on Emacs. But if the question means Remacs-only contributors, then we can check for anyone who has modified a Rust file:

{% highlight shell %}
git log --format='%an' -- '*.rs' | sort -u | wc -l
{% endhighlight %}

That gives 103 as I write this. Accounting for duplicates and false positives, let's call it around **80**. I would guess that between half and three quarters of those are **drive-bys**.


<a id="orgf014e6c"></a>

# Where has Remacs been discussed?

Blog posts from the creator of Remacs: [1](http://www.wilfred.me.uk/blog/2017/04/30/remacs-talk-transcript/) [2](http://www.wilfred.me.uk/blog/2017/01/19/this-week-in-remacs/) [3](http://www.wilfred.me.uk/blog/2017/02/05/these-weeks-in-remacs/) [4](http://www.wilfred.me.uk/blog/2017/07/15/these-weeks-in-remacs-ii/) [5](http://www.wilfred.me.uk/blog/2017/10/16/these-weeks-in-remacs-iii/)

Hacker News: [1](https://news.ycombinator.com/item?id=13378247) [2](https://news.ycombinator.com/item?id=14782380) [3](https://news.ycombinator.com/item?id=18182742) [4](https://news.ycombinator.com/item?id=19276751)

Reddit: [1](https://www.reddit.com/r/emacs/comments/8tovcg/ask_reddit_remacs_whos_using_remacs/) [2](https://www.reddit.com/r/emacs/comments/a40s6d/emacs_maintainers_view_of_the_remacs_emacs_port/) [3](https://www.reddit.com/r/emacs/comments/76u8sb/these_weeks_in_remacs_iii/) [4](https://www.reddit.com/r/rust/comments/704vs3/remacs_worth_it/)


<a id="orga947ef6"></a>

# Where has this FAQ been discussed?

Reddit: [1](https://www.reddit.com/r/emacs/comments/befzdd/remacs_faq/)
