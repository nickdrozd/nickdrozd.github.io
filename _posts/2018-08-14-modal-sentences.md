---
title: "Logic in Reazon I: Generating Sentences of Modal Logic"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2018-08-14 Tue&gt;</span></span>
layout: post
categories:
tags:
---
Here's a description of the language of modal logic from Boolos's *[The Logic of Provability](https://books.google.com/books?id=WekaT3OLoUcC&lpg=PP1&dq=logic%2520of%2520provability&pg=PA2#v=onepage&q&f=false)*:

> **Modal sentences.** Fix a countably infinite sequence of distinct objects, of which the first five are `⊥`, `→`, `□`, `(`, `)`, and the others are the sentence letters&#x2026; Modal sentences will be certain finite sequences of these objects. We shall use `A`, `B`, &#x2026; as variables over modal sentences. Here is an inductive definition of ***modal sentence***:
>
> (1) `⊥` is a modal sentence;
>
> (2) each sentence letter is a modal sentence;
>
> (3) if `A` and `B` are modal sentences, so is `(A → B)`; and
>
> (4) if `A` is a modal sentence, so is `□(A)`.
>
> [We shall very often write: `(A → B)` and: `□(A)` as: `A → B` and: `□A`.]
>
> Sentences that do not contain sentence letters are *letterless*. For example, `⊥`, `□⊥`, and `□⊥ → ⊥` are letterless sentences.

It's easy to translate this into a definition in [Reazon miniKanren](https://github.com/nickdrozd/reazon):

{% highlight emacs-lisp %}
(reazon-defrel modal-logic-sentence (s)
  (reazon-disj
   ;; (1)
   (reazon-== s '⊥)
   ;; (2)
   (reazon-fresh (p)
     (reazon-== s p))
   ;; (3)
   (reazon-fresh (A B)
     (modal-logic-sentence A)
     (modal-logic-sentence B)
     (reazon-== s `(,A → ,B)))
   ;; (4)
   (reazon-fresh (A)
     (modal-logic-sentence A)
     (reazon-== s `(□ ,A)))))
{% endhighlight %}

And given such a definition, it's even easier to generate instances:

{% highlight emacs-lisp %}
(reazon-run 10 q (modal-logic-sentence q))
{% endhighlight %}

-   ⊥
-   \_0
-   (□ ⊥)
-   (□ \_0)
-   (⊥ → ⊥)
-   (⊥ → \_0)
-   (□ (□ ⊥))
-   (□ (□ \_0))
-   (<sub>0</sub> → ⊥)
-   (<sub>0</sub> → \_1)

All possible modal logic sentences would eventually be generated from that definition.

It's also easy to add new syntax, like the negation operator `¬`.

{% highlight emacs-lisp %}
(reazon-defrel modal-logic-sentence (s)
  (reazon-disj
   (reazon-== s '⊥)
   (reazon-fresh (p)
     (reazon-== s p))
   ;; ¬
   (reazon-fresh (A)
     (modal-logic-sentence A)
     (reazon-== s `(¬ ,A)))
   (reazon-fresh (A B)
     (modal-logic-sentence A)
     (modal-logic-sentence B)
     (reazon-== s `(,A → ,B)))
   (reazon-fresh (A)
     (modal-logic-sentence A)
     (reazon-== s `(□ ,A)))))
{% endhighlight %}

We can also tweak the definition to generate specific subsets of sentences. For example, the letterless sentences mentioned above contain some interesting cases, like `¬□⊥ → ¬□¬□⊥`. Under the provability interpretation of modal logic, this sentence says that if there is no proof of a falsehood then there is no proof that there is no proof of a falsehood, i.e. [Goedel's second incompleteness theorem](https://nickdrozd.github.io/2018/08/13/incompleteness.html).

To get the letterless sentences, simply don't include the sentence letters.

{% highlight emacs-lisp %}
(reazon-defrel modal-logic-sentence (s)
  (reazon-disj
   (reazon-== s '⊥)
   ;; (reazon-fresh (p)
   ;;   (reazon-== s p))
   (reazon-fresh (A)
     (modal-logic-sentence A)
     (reazon-== s `(¬ ,A)))
   (reazon-fresh (A B)
     (modal-logic-sentence A)
     (modal-logic-sentence B)
     (reazon-== s `(,A → ,B)))
   (reazon-fresh (A)
     (modal-logic-sentence A)
     (reazon-== s `(□ ,A)))))
{% endhighlight %}

{% highlight emacs-lisp %}
(reazon-run 10 q (modal-logic-sentence q))
{% endhighlight %}

-   ⊥
-   (¬ ⊥)
-   (¬ (¬ ⊥))
-   (□ ⊥)
-   (⊥ → ⊥)
-   (¬ (¬ (¬ ⊥)))
-   (□ (¬ ⊥))
-   (¬ (□ ⊥))
-   (¬ (⊥ → ⊥))
-   (⊥ → (¬ ⊥))

We're getting some interesting sentences, like `(¬ (□ ⊥))`, but also a lot of junk, like `(⊥ → ⊥)` and `(¬ (¬ (¬ ⊥)))`. We can fix this by applying `¬` only to sentences beginning with `□` and by applying `→` only to compound sentences.

{% highlight emacs-lisp %}
(reazon-defrel modal-logic-sentence (s)
  (reazon-disj
   (reazon-== s '⊥)
   (reazon-fresh (p)
     ;; Apply negation only to boxed sentences.
     (reazon-fresh (a d)
       (reazon-== a '□)
       (reazon-== p (cons a d)))
     (reazon-== s `(¬ ,p))
     (modal-logic-sentence p))
   (reazon-fresh (p q)
     (reazon-== s `(,p → ,q))
     ;; Apply conditional only to compound sentences.
     (reazon-fresh (a d)
       (reazon-== p (cons a d)))
     (modal-logic-sentence p)
     (reazon-fresh (a d)
       (reazon-== q (cons a d)))
     (modal-logic-sentence q))
   (reazon-fresh (p)
     (reazon-== s `(□ ,p))
     (modal-logic-sentence p))))
{% endhighlight %}

{% highlight emacs-lisp %}
(reazon-run 23 q (modal-logic-sentence q))
{% endhighlight %}

-   ⊥
-   (¬ (□ ⊥))
-   (□ ⊥)
-   (¬ (□ (¬ (□ ⊥))))
-   (¬ (□ (□ ⊥)))
-   (□ (¬ (□ ⊥)))
-   (¬ (□ (¬ (□ (¬ (□ ⊥))))))
-   (□ (□ ⊥))
-   (¬ (□ (¬ (□ (□ ⊥)))))
-   (¬ (□ (□ (¬ (□ ⊥)))))
-   (□ (¬ (□ (¬ (□ ⊥)))))
-   (¬ (□ (¬ (□ (¬ (□ (¬ (□ ⊥))))))))
-   ((¬ (□ ⊥)) → (¬ (□ ⊥)))
-   (¬ (□ (□ (□ ⊥))))
-   (□ (¬ (□ (□ ⊥))))
-   (¬ (□ (¬ (□ (¬ (□ (□ ⊥)))))))
-   ((¬ (□ ⊥)) → (□ ⊥))
-   (□ (□ (¬ (□ ⊥))))
-   (¬ (□ (¬ (□ (□ (¬ (□ ⊥)))))))
-   (¬ (□ (□ (¬ (□ (¬ (□ ⊥)))))))
-   (□ (¬ (□ (¬ (□ (¬ (□ ⊥)))))))
-   (¬ (□ (¬ (□ (¬ (□ (¬ (□ (¬ (□ ⊥))))))))))
-   ((¬ (□ ⊥)) → (¬ (□ (¬ (□ ⊥)))))

The twenty-third statement generated from this definition is `((¬ (□ ⊥)) → (¬ (□ (¬ (□ ⊥)))))`, the modal logic statement of the second incompleteness theorem. Further on can be found its converse `((□ ⊥) → (□ (¬ (□ ⊥))))`, and further still can be found `((□ ⊥) → (□ (□ ⊥)))`, an instance of one of the [Hilbert-Bernays derivability conditions](https://en.wikipedia.org/wiki/Hilbert%25E2%2580%2593Bernays_provability_conditions).

We can also generate *substitution instances*. Take the *modal distribution axiom* `((□ (A → B)) → ((□ A) → (□ B)))`.

{% highlight emacs-lisp %}
(reazon-run 10 q
  (reazon-fresh (A B)
    (modal-logic-sentence A)
    (modal-logic-sentence B)
    (reazon-== q `((□ (,A → ,B)) → ((□ ,A) → (□ ,B))))))
{% endhighlight %}

-   ((□ (⊥ → ⊥)) → ((□ ⊥) → (□ ⊥)))
-   ((□ (⊥ → (¬ (□ ⊥)))) → ((□ ⊥) → (□ (¬ (□ ⊥)))))
-   ((□ ((¬ (□ ⊥)) → ⊥)) → ((□ (¬ (□ ⊥))) → (□ ⊥)))
-   ((□ (⊥ → (□ ⊥))) → ((□ ⊥) → (□ (□ ⊥))))
-   ((□ (⊥ → (¬ (□ (¬ (□ ⊥)))))) → ((□ ⊥) → (□ (¬ (□ (¬ (□ ⊥)))))))
-   ((□ ((¬ (□ ⊥)) → (¬ (□ ⊥)))) → ((□ (¬ (□ ⊥))) → (□ (¬ (□ ⊥)))))
-   ((□ ((□ ⊥) → ⊥)) → ((□ (□ ⊥)) → (□ ⊥)))
-   ((□ (⊥ → (¬ (□ (□ ⊥))))) → ((□ ⊥) → (□ (¬ (□ (□ ⊥))))))
-   ((□ ((¬ (□ ⊥)) → (□ ⊥))) → ((□ (¬ (□ ⊥))) → (□ (□ ⊥))))
-   ((□ (⊥ → (□ (¬ (□ ⊥))))) → ((□ ⊥) → (□ (□ (¬ (□ ⊥))))))

Notice that the third result, `((□ ((¬ (□ ⊥)) → ⊥)) → ((□ (¬ (□ ⊥))) → (□ ⊥)))`, contains the contrapositive of the second incompleteness theorem as its consequent.
