---
title: "Solving Logic Puzzles in Emacs with Reazon"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2018-08-07 Tue&gt;</span></span>
layout: post
categories:
tags:
---
**[Reazon](https://github.com/nickdrozd/reazon)** is an **Emacs** implementation of the **miniKanren** logic programming language. As of version [0.1](https://github.com/nickdrozd/reazon/releases/tag/0.1) it contains just a basic equality relation and no constraints. In particular, it lacks a **disequality** constraint; while it is possible to say that the value of variable `x` is `5`, it is *not* possible to say that the value of variable `x` is *not* `5`.

With a little cleverness and some dull labor, it is sometimes possible to circumvent this limitation by expressing a negative in terms of positives. Consider the following logic puzzle<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>:

> Baker, Cooper, Fletcher, Miller, and Smith live on different floors of an apartment house that contains only five floors. Baker does not live on the top floor. Cooper does not live on the bottom floor. Fletcher does not live on either the top or the bottom floor. Miller lives on a higher floor than does Cooper. Smith does not live on a floor adjacent to Fletcher's. Fletcher does not live on a floor adjacent to Cooper's. Where does everyone live?

We're given that the building has exactly five floors, and our goal is to figure out the ordering of the residents in the building. We know immediately that there can only be **finitely many solutions**, so we can safely use `reazon-run*` to find all of them. Using `q` as our query variable, we can start to sketch out a solution. We'll represent the building as a list with five items, the first of which represents the bottom floor and the last of which represents the top floor.

{% highlight emacs-lisp %}
(reazon-run* q
  ;; ...an apartment house that contains only five floors.
  (reazon-fresh (a b c d e)
    (reazon-== q `(,a ,b ,c ,d ,e))))
{% endhighlight %}

The next clue is stated as a negative: "Baker does not live on the top floor." We can't express negatives, so how can we proceed? Let's think about it without doing any programming. Where does Baker live? She<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup> isn't on the top (fifth) floor, so she must be on the first floor or the second floor or the third floor or the fourth floor. Well, there's our positive statement right there!

{% highlight emacs-lisp %}
(reazon-run* q
  (reazon-fresh (a b c d e)
    ;; Baker does not live on the top floor.
    (reazon-disj
     (reazon-== q `(baker ,b ,c ,d ,e))
     (reazon-== q `(,a baker ,c ,d ,e))
     (reazon-== q `(,a ,b baker ,d ,e))
     (reazon-== q `(,a ,b ,c baker ,e)))))
{% endhighlight %}

This repetitive list of alternatives is **inelegant**, and it's **not even correct**, as it doesn't preclude the possibility of Baker's being on the fifth floor, but for now it's the best we can do. Note that this clause implies that `q` is a list of five elements, so we can actually delete our first clause.

The next two clues can be handled similarly.

{% highlight emacs-lisp %}
(reazon-run* q
  (reazon-fresh (a b c d e)
    ;; Baker...
    ;; Cooper does not live on the bottom floor.
    (reazon-disj
     (reazon-== q `(,a cooper ,c ,d ,e))
     (reazon-== q `(,a ,b cooper ,d ,e))
     (reazon-== q `(,a ,b ,c cooper ,e))
     (reazon-== q `(,a ,b ,c ,d cooper)))
    ;; Fletcher does not live on either the top or the bottom floor.
    (reazon-disj
     (reazon-== q `(,a fletcher ,c ,d ,e))
     (reazon-== q `(,a ,b fletcher ,d ,e))
     (reazon-== q `(,a ,b ,c fletcher ,e)))))
{% endhighlight %}

The next clue is different: "Miller lives on a higher floor than does Cooper." The general way to handle such a clue would be to write a relation like `(precedes x y s)`, meaning `x` precedes `y` in `s`. Our problem domain is small, though, so we'll just stick to primitives. This clue adds some new possibilities (if Cooper is on the second floor, Miller could be on floor three, four, or five), but it also removes some (we know Cooper can't be on the top floor).

{% highlight emacs-lisp %}
(reazon-run* q
  (reazon-fresh (a b c d e)
    ;; Baker...
    (reazon-disj
     ;; Cooper does not live on the bottom floor.
     ;; Miller lives on a higher floor than does Cooper.
     (reazon-== q `(,a cooper miller ,d ,e))
     (reazon-== q `(,a cooper ,c miller ,e))
     (reazon-== q `(,a cooper ,c ,d miller))
     (reazon-== q `(,a ,b cooper miller ,e))
     (reazon-== q `(,a ,b cooper ,d miller))
     (reazon-== q `(,a ,b ,c cooper miller)))
    ;; Fletcher...
    ))
{% endhighlight %}

The final two clues both mention Fletcher, so we will handle them in the Fletcher disjunction: "Smith does not live on a floor adjacent to Fletcher's. Fletcher does not live on a floor adjacent to Cooper's." Adjancency is a symmetric relation, so we can say that neither Smith nor Cooper live on a floor adjacent to Fletcher. Thus if Fletcher lives on the second floor, neither Smith nor Cooper can live on the the first or third floors, and therefore must live on the fourth and fifth floors. These and the other cases are easy enough to add in:

{% highlight emacs-lisp %}
(reazon-run* q
  (reazon-fresh (a b c d e)
    ;; Baker...
    ;; Cooper, Miller...
    ;; Fletcher does not live on either the top or the bottom floor.
    ;; Smith does not live on a floor adjacent to Fletcher's.
    ;; Fletcher does not live on a floor adjacent to Cooper's.
    (reazon-disj
     (reazon-== q `(,a fletcher ,c smith cooper))
     (reazon-== q `(,a fletcher ,c cooper smith))
     (reazon-== q `(smith ,b fletcher ,d cooper))
     (reazon-== q `(cooper ,b fletcher ,d smith))
     (reazon-== q `(smith cooper ,c fletcher ,e))
     (reazon-== q `(cooper smith ,c fletcher ,e)))))
{% endhighlight %}

Putting the pieces together, our solver yields results:

{% highlight emacs-lisp %}
(reazon-run* q
  ;; ...an apartment house that contains only five floors.
  (reazon-fresh (a b c d e)
    ;; Baker does not live on the top floor.
    (reazon-disj
     (reazon-== q `(baker ,b ,c ,d ,e))
     (reazon-== q `(,a baker ,c ,d ,e))
     (reazon-== q `(,a ,b baker ,d ,e))
     (reazon-== q `(,a ,b ,c baker ,e)))
    (reazon-disj
     ;; Cooper does not live on the bottom floor.
     ;; Miller lives on a higher floor than does Cooper.
     (reazon-== q `(,a cooper miller ,d ,e))
     (reazon-== q `(,a cooper ,c miller ,e))
     (reazon-== q `(,a cooper ,c ,d miller))
     (reazon-== q `(,a ,b cooper miller ,e))
     (reazon-== q `(,a ,b cooper ,d miller))
     (reazon-== q `(,a ,b ,c cooper miller)))
    (reazon-disj
     ;; Fletcher does not live on either the top or the bottom floor.
     ;; Smith does not live on a floor adjacent to Fletcher's.
     ;; Fletcher does not live on a floor adjacent to Cooper's.
     (reazon-== q `(,a fletcher ,c smith cooper))
     (reazon-== q `(,a fletcher ,c cooper smith))
     (reazon-== q `(smith ,b fletcher ,d cooper))
     (reazon-== q `(cooper ,b fletcher ,d smith))
     (reazon-== q `(smith cooper ,c fletcher ,e))
     (reazon-== q `(cooper smith ,c fletcher ,e)))))
{% endhighlight %}

    ((smith cooper baker fletcher miller))

In fact, it yields **exactly one solution**. If we trust the language (???), then we can conclude that there are no others.

Suppose we omit the requirement that Smith and Fletcher do not live on adjacent floors. How many solutions are there then?<sup><a id="fnr.3" class="footref" href="#fn.3">3</a></sup>

{% highlight emacs-lisp %}
(reazon-run* q
  ;; ...an apartment house that contains only five floors.
  (reazon-fresh (a b c d e)
    ;; Baker does not live on the top floor.
    (reazon-disj
     (reazon-== q `(baker ,b ,c ,d ,e))
     (reazon-== q `(,a baker ,c ,d ,e))
     (reazon-== q `(,a ,b baker ,d ,e))
     (reazon-== q `(,a ,b ,c baker ,e)))
    (reazon-disj
     ;; Cooper does not live on the bottom floor.
     ;; Miller lives on a higher floor than does Cooper.
     (reazon-== q `(,a cooper miller ,d ,e))
     (reazon-== q `(,a cooper ,c miller ,e))
     (reazon-== q `(,a cooper ,c ,d miller))
     (reazon-== q `(,a ,b cooper miller ,e))
     (reazon-== q `(,a ,b cooper ,d miller))
     (reazon-== q `(,a ,b ,c cooper miller)))
    (reazon-disj
     ;; Fletcher does not live on either the top or the bottom floor.
     ;; Fletcher does not live on a floor adjacent to Cooper's.
     (reazon-== q `(,a fletcher ,c ,d cooper))
     (reazon-== q `(,a fletcher ,c cooper ,e))
     (reazon-== q `(,a ,b fletcher ,d cooper))
     (reazon-== q `(cooper ,b fletcher ,d ,e))
     (reazon-== q `(,a cooper ,c fletcher ,e))
     (reazon-== q `(cooper ,b ,c fletcher ,e)))
    ;; Smith's floor is not restricted.
    (reazon-disj
     (reazon-== q `(smith ,b ,c ,d ,e))
     (reazon-== q `(,a smith ,c ,d ,e))
     (reazon-== q `(,a ,b smith ,d ,e))
     (reazon-== q `(,a ,b ,c smith ,e))
     (reazon-== q `(,a ,b ,c ,d smith)))))
{% endhighlight %}

    ((baker cooper miller fletcher smith) (baker cooper smith fletcher miller) (baker fletcher smith cooper miller) (smith cooper baker fletcher miller) (smith fletcher baker cooper miller))

This time there are five results.<sup><a id="fnr.4" class="footref" href="#fn.4">4</a></sup>

Now, you might say: we basically solved the problem ourselves by explicitly typing out the possibilities, so **what's the point of using miniKanren at all?**

First, this was not meant to be an example of good miniKanren programming technique, but rather a demonstration that a certain class of problem is in principle within the grasp of Reazon 0.1. Second, even with just the cases laid out in the final form of the solver, it would *still* be a pain to have to settle the problem manually, so miniKanren really did help us in the end.

Finally, let's take a step back and look at the outline of our solver. In general, a query of the form

{% highlight emacs-lisp %}
(reazon-run* q
  goal-1
  ;; ...
  goal-n)
{% endhighlight %}

will attempt to find values for `q` satisfying all of `goal-1` &#x2026; `goal-n`. This is equivalent to querying against the single goal that is the conjunction of all those goals.

{% highlight emacs-lisp %}
(reazon-run* q
  (reazon-conj
   goal-1
   ;; ...
   goal-n))
{% endhighlight %}

In our solver, all the goals are disjunctions, so this looks like

{% highlight emacs-lisp %}
(reazon-run* q
  (reazon-conj
   (reazon-disj goal-1-1 ... goal-1-n)
   ;; ...
   (reazon-disj goal-n-1 ... goal-n-n)))
{% endhighlight %}

In other words, our solver is a conjunction of disjunctions. This is what logicians call ***[conjunctive normal form](https://en.wikipedia.org/wiki/Conjunctive_normal_form)***.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> This problem is used as an example in [SICP section 4.3.2](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-28.html#%25_sec_4.3.2) to illustrate the advantages of a [nondeterministic](https://en.wikipedia.org/wiki/Nondeterministic_programming) variant of Scheme. Their solution is quite different from the one presented here.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> The writer(s) of this puzzle probably assumed that these names referred to men. In contrast, I assume that "Baker" is actually smooth jazz legend [Anita Baker](https://en.wikipedia.org/wiki/Anita_Baker).

<sup><a id="fn.3" href="#fnr.3">3</a></sup> This is [SICP exercise 4.38](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-28.html#%25_thm_4.38).

<sup><a id="fn.4" href="#fnr.4">4</a></sup> Just to be sure, I checked these answers against those of [Eli Bendersky](https://eli.thegreenplace.net/2008/01/05/sicp-section-432). Somehow his answers came out in the same order as these ones. Why is that?
