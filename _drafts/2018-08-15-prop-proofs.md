---
title: "Logic in Reazon II: Generating Propositional Logic Proofs"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2018-08-15 Wed&gt;</span></span>
layout: post
categories:
tags:
---
An axiomatic logical system consists of **axioms** and **rules of inference**, where an axiom is a statement stipulated to be provable and a rule of inference is a description of how to obtain new provable statements from old ones. A **theorem** is either an axiom or the result of applying a rule of inference to one or more theorems, and a **proof** is a sequence of statements such that every statement is either an axiom or a theorem obtained by applying a rule of inference to previous statements in the sequence.

**Classical propositional logic** is encompassed by the following axioms<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>, along with one rule of inference:

1.  `p →. q → p`
2.  `p →. q → r :→: p → q .→. p → q`
3.  `¬p → ¬q .→. q → p`

*Modus ponens*: If `p → q` and `p` are theorems, then so is `q`.

**Intuitively**, (1) says that a true statement is implied by anything, (2) says that implication is transitive, and (3) says that implication is contraposable.

Given all these definitions, it's possible (indeed, easy!) to write a program in **[Reazon miniKanren](https://github.com/nickdrozd/reazon)** to **generate propositional logic proofs**.

Propositional formulae will be represented with a Lispy syntax (i.e., with lots of parentheses). A **justification** will be one of the symbols `A1`, `A2`, `A3`, or `MP`, and a **step** will be a list whose first element is a justification and whose second element is a formula. A **proof** will be a list of steps ordered from "latest" to "earliest". I don't have a rigorous definition of the ordering, but basically the first element of a proof list will be the theorem being proved, elements in the middle will be intermediate steps, and the last elements will be axioms. The ordering is complicated by the fact that proofs can be nested.

But this all makes it seem more complicated than it really is. The code is short and simple<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup>:

{% highlight emacs-lisp %}
(reazon-defrel prop-logic-proof (s)
  (reazon-disj
   ;; A1
   (reazon-fresh (p q)
     (reazon-== s `((A1 (,p → (,q → ,p))))))
   ;; A2
   (reazon-fresh (p q r)
     (reazon-== s `((A2 ((,p → (,q → ,r)) → ((,p → ,q) → (,p → ,r)))))))
   ;; A3
   (reazon-fresh (p q)
     (reazon-== s `((A3 (((¬ ,p) → (¬ ,q)) → (,q → ,p))))))
   ;; MP
   (reazon-fresh (p q r1 r2 j1 j2 d1 d2)
     (reazon-== r1 `((,j1 ,p) . ,d1))
     (prop-logic-proof r1)
     (reazon-== r2 `((,j2 (,p → ,q)) . ,d2))
     (prop-logic-proof r2)
     (reazon-== s `((MP ,q) ,r1 ,r2)))))
{% endhighlight %}

Let's look at the first four proofs generated from this definition.

{% highlight emacs-lisp %}
(reazon-run 4 q (prop-logic-proof q))
{% endhighlight %}

-   `((A1 (_0 → (_1 → _0))))`
-   `((A2 ((_0 → (_1 → _2)) → ((_0 → _1) → (_0 → _2)))))`
-   `((A3 (((¬ _0) → (¬ _1)) → (_1 → _0))))`
-   `((MP (_0 → (_1 → (_2 → _1)))) ((A1 (_1 → (_2 → _1)))) ((A1 ((_1 → (_2 → _1)) → (_0 → (_1 → (_2 → _1)))))))`

The first three "proofs" are just the axioms, which are **self-justifying**. The fourth proof has a little more going on. With better formatting:

{% highlight emacs-lisp %}
'((MP (_0 → (_1 → (_2 → _1))))
  ((A1 (_1 → (_2 → _1))))
  ((A1 ((_1 → (_2 → _1)) → (_0 → (_1 → (_2 → _1)))))))
{% endhighlight %}

The conclusion of the proof (i.e., the theorem to be proved) is `(_0 → (_1 → (_2 → _1)))`. The first statement in the proof is an instance of (1), where `p` is `_1` and `q` is `_2`. The second statement is another instance of (1), where `p` is `(_1 → (_2 → _1))` and `q` is `_0`. Finally, the conclusion is obtained by an application of *modus ponens* to those two statements.

**Boring** for sure, but that is nonetheless a real, accurate, full-blown proof!

I ran this definition for the first one hundred results, which took two or three seconds on a 2012 MBP. The hundredth theorem is not bad: `(((¬ _0) → (¬ (_1 → (_2 → _1)))) → _0)`. This says that if the negation of a statement implies the negation of (1), then that statement is true, which is an instance of **reasoning by contradiction**. Here is the proof:

{% highlight emacs-lisp %}
'((MP (((¬ _0) → (¬ (_1 → (_2 → _1)))) → _0))
  ((MP (((¬ _0) → (¬ (_1 → (_2 → _1)))) → (_1 → (_2 → _1))))
   ((A1 (_1 → (_2 → _1))))
   ((A1 ((_1 → (_2 → _1)) → (((¬ _0) → (¬ (_1 → (_2 → _1)))) → (_1 → (_2 → _1)))))))
  ((MP ((((¬ _0) → (¬ (_1 → (_2 → _1)))) → (_1 → (_2 → _1))) → (((¬ _0) → (¬ (_1 → (_2 → _1)))) → _0)))
   ((A3 (((¬ _0) → (¬ (_1 → (_2 → _1)))) → ((_1 → (_2 → _1)) → _0))))
   ((A2 ((((¬ _0) → (¬ (_1 → (_2 → _1)))) → ((_1 → (_2 → _1)) → _0)) → ((((¬ _0) → (¬ (_1 → (_2 → _1)))) → (_1 → (_2 → _1))) → (((¬ _0) → (¬ (_1 → (_2 → _1)))) → _0)))))))
{% endhighlight %}

Of the first one hundred proofs generated, twenty (!!!) are proofs of the "theorem" `(_0 → (_1 → _0))` (the first axiom). Some of these proofs are quite long, for example:

{% highlight emacs-lisp %}
'((MP (_0 → (_1 → _0)))
  ((A1 (_2 → (_3 → _2))))
  ((MP ((_2 → (_3 → _2)) → (_0 → (_1 → _0))))
   ((A1 (_0 → (_1 → _0))))
   ((MP ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))))
    ((A1 (_4 → (_5 → _4))))
    ((MP ((_4 → (_5 → _4)) → ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0))))))
     ((A1 ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0))))))
     ((MP (((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))) → ((_4 → (_5 → _4)) → ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))))))
      ((A1 (_6 → (_7 → _6))))
      ((MP ((_6 → (_7 → _6)) → (((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))) → ((_4 → (_5 → _4)) → ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0))))))))
       ((A1 (((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))) → ((_4 → (_5 → _4)) → ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0))))))))
       ((A1 ((((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))) → ((_4 → (_5 → _4)) → ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))))) → ((_6 → (_7 → _6)) → (((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0)))) → ((_4 → (_5 → _4)) → ((_0 → (_1 → _0)) → ((_2 → (_3 → _2)) → (_0 → (_1 → _0))))))))))))))))
{% endhighlight %}

This proof consists of repeated applications of *modus ponens* to nested instances of (1) using eight (!!!) different variables. This is as inane as it sounds, but it does appear to be a valid proof.

In the expression that generated these results (`(reazon-run 4 q (prop-logic-proof q))`), the query variable `q` was left free. We can also generate proofs of specific theorems by specifying the form of the query variable. For instance, we can find proofs of theorems of the form `¬¬p → p` (i.e. double negation elimination):

{% highlight emacs-lisp %}
(reazon-run 1 q
  (reazon-fresh (p d)
    (reazon-== q `((MP ((¬ (¬ ,p)) → ,p)) . ,d))
    (prop-logic-proof q)))
{% endhighlight %}

{% highlight emacs-lisp %}
'(((MP ((¬ (¬ (_0 → (_1 → _0)))) → (_0 → (_1 → _0))))
   ((A1 (_0 → (_1 → _0))))
   ((A1 ((_0 → (_1 → _0)) → ((¬ (¬ (_0 → (_1 → _0)))) → (_0 → (_1 → _0))))))))
{% endhighlight %}

Of the first one hundred results for this query, none of the theorems proved are actually `((¬ (¬ _0)) → _0)`, which is what I wanted. Instead, they all replace that free variable `_0` with some theorem (often an axiom, as above). It's not clear to me if this is due to a flaw in the definition of proof (is there something being left out?), in Reazon itself (is the search really complete?), or if such a theorem really would eventually be proved given enough time. Would it show up in the first thousand results? The first million? [This proof](https://math.stackexchange.com/a/1131671) of double negation elimination uses three (!!!) intermediate lemmas, so maybe it just requires a long proof.

<a id="org20238c7"></a>
Finally, the proof "generator" can also be used as proof verifier. In this case, we'll bind the query variable to some arbitrary symbol, and the presence or absence of that symbol in the output will indicate the validity of the proof.

{% highlight emacs-lisp %}
(reazon-run 1 q
  (prop-logic-proof
   '((MP (_0 → (_1 → (_2 → _1))))
     ((A1 (_1 → (_2 → _1))))
     ((A1 ((_1 → (_2 → _1)) → (_0 → (_1 → (_2 → _1))))))))
  (reazon-== q 'proof-looks-good!))
{% endhighlight %}

| proof-looks-good! |

{% highlight emacs-lisp %}
(reazon-run 1 q
  (prop-logic-proof
   '((MP (_0 → (_1 → (_2 → _1))))
     ((A1 (_2 → (_2 → _1)))) ;; <-- wrong!
     ((A1 ((_1 → (_2 → _1)) → (_0 → (_1 → (_2 → _1))))))))
  (reazon-== q 'proof-looks-good!))
{% endhighlight %}

    nil

<a id="org43c60a9"></a>
**Postscript**

As I was writing the section on [proof verification](#org20238c7), I discovered a bug in the definition of `prop-logic-proof`. The rule for *modus ponens* given above looks like this:

{% highlight emacs-lisp %}
(reazon-fresh (p q r1 r2 j1 j2 d1 d2)
  (reazon-== r1 `((,j1 ,p) . ,d1))
  (prop-logic-proof r1)
  (reazon-== r2 `((,j2 (,p → ,q)) . ,d2))
  (prop-logic-proof r2)
  (reazon-== s `((MP ,q) ,r1 ,r2)))
{% endhighlight %}

This definition causes the following query to go into an infinite loop:

{% highlight emacs-lisp %}
(reazon-run 1 q
  (prop-logic-proof
   '((A1 (_0 → (_1 → _0)))))
  (reazon-== q 'proof-looks-good!))
{% endhighlight %}

An important principle of writing miniKanren programs is: **always put the recursive calls last**. This change fixes the problem:

{% highlight emacs-lisp %}
(reazon-fresh (p q r1 r2 j1 j2 d1 d2)
  (reazon-== s `((MP ,q) ,r1 ,r2))
  (reazon-== r1 `((,j1 ,p) . ,d1))
  (reazon-== r2 `((,j2 (,p → ,q)) . ,d2))
  ;; Recursive calls last!
  (prop-logic-proof r1)
  (prop-logic-proof r2))
{% endhighlight %}

{% highlight emacs-lisp %}
(reazon-run 1 q
  (prop-logic-proof
   '((A1 (_0 → (_1 → _0)))))
  (reazon-== q 'proof-looks-good!))
{% endhighlight %}

| proof-looks-good! |

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> Due to Lukasiewicz, according to Wikipedia.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> Actually, this definition contains a subtle error. See the [postscript](#org43c60a9).
