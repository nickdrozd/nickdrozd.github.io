---
title: "Propositional Logic Theorems as Types (in Idris)"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2019-04-10 Wed&gt;</span></span>
layout: post
categories:
tags:
---
Suppose you have a function from `Int` to `Char` and an `Int` and you need a `Char`. How can you get one? In other words, how would you implement the function `A : (Int -> Char) -> Int -> Char`? Easy, just apply the function to the argument: `A f x = f x`.

Okay, now suppose you have a function from `Int` to `Char` and a function from `Char` to `String` and an `Int`. How can you get a `String`? In other words, how can you implement `B : (Int -> Char) -> (Char -> String) -> Int -> String`? Still easy: `B f g x = g (f x)`.

Finally, suppose you have a function from `Int` to `Char` to `String` and a function from `Int` to `Char` and an `Int`. Again, how can you get a `String`? In other words, how can you implement `C : (Int -> Char -> String) -> (Int -> Char) -> Int -> String`. Again, easy: `C f g x = f x (g x)`.

You might notice that these functions seem to have an **algebraic** character, and don't have anything to do with `Int`, `Char`, or `String` in particular. That's true, and so the signatures can be rewritten **generically**: `A : (p -> q) -> p -> q`, `B : (p -> q) -> (q -> r) -> p -> r`, and `A : (p -> q -> r) -> (p -> q) -> p -> r` (the implementations can be left alone).

At this point you might look at these signature and notice that they bear a striking similarity to certain theorems of **propositional logic**, namely [modus ponens](https://en.wikipedia.org/wiki/Modus_ponens), [hypothetical syllogism](https://en.wikipedia.org/wiki/Hypothetical_syllogism), and [Frege's theorem](https://en.wikipedia.org/wiki/Frege's_theorem#Frege's_theorem_in_propositional_logic), respectively. If you thought this, then congratulations, you've just discovered the first part of the **[Curry-Howard correspondence](https://en.wikipedia.org/wiki/Curry%25E2%2580%2593Howard_correspondence)**. The "correspondence" is the **deep isomorphism** between **types and programs**, on the one hand, and **propositions and proofs** on the other. The first part of the correspondence has to do with **propositional logic** and was discovered by Curry in the 1930s. The second part has to do with **quantificational logic**, and was discovered by Howard several decades later. (We'll ignore the second part for now.)

Here's a theorem for joining inferences:

{% highlight nil %}
joinInference : (p -> q) -> (r -> s) -> (q -> r) -> p -> s
joinInference f h g x = h (g (f x))
{% endhighlight %}

We can also prove **[double negation](https://en.wikipedia.org/wiki/Double_negation) introduction** (where `p -> Void`<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup> stands in for *p → ⊥*, which is equivalent to *¬p*)<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup>:

{% highlight nil %}
dni : p -> (p -> Void) -> Void
dni x f = f x
{% endhighlight %}

What about **double negation elimination** (DNE)?

{% highlight nil %}
dne : ((p -> Void) -> Void) -> p
{% endhighlight %}

Not so fast! It turns out that the type systems used by languages like **Idris** and **Haskell** don't correspond to **classical logic**, but rather to **intuitionistic logic**<sup><a id="fnr.3" class="footref" href="#fn.3">3</a></sup>. Intuitionistic logic is like classical logic except that it doesn't validate the **[principle of the excluded middle](https://en.wikipedia.org/wiki/Double_negation)** (PEM): *p ∨ ¬p*. That is, it's not the case that for any proposition, either that proposition or its negation holds, and a double negative is *not* [proof positive](https://www.youtube.com/watch?v=PKo7Ivssqfk).

To see why someone might reject PEM, consider the following classic argument.

> ***Claim*** There are irrational numbers *a* and *b* such that *a<sup>b</sup>* is rational.
>
> ***Proof*** The number √2<sup>(√2)</sup> is either rational or it isn't. If it is, let *a = b = √2* and we're done. Otherwise, let *a = √2<sup>(√2)</sup>* and let *b = √2*. Then *a<sup>b</sup> = (√2<sup>(√2)</sup>)<sup>(√2)</sup> = √2<sup>(√2 \* √2)</sup> = √2<sup>2</sup> = √2 \* √2 = 2*. Tada!

There's something *off* about this proof. It says that numbers with some property exist, but it doesn't give **witnesses**; without witnesses, the knowledge feels hollow. The critical point in the proof is this line: *The number √2<sup>(√2)</sup> is either rational or it isn't.* But this is an instance of PEM! So you might forbid reasoning with PEM in order to preclude proofs like this one.<sup><a id="fnr.4" class="footref" href="#fn.4">4</a></sup>

Anyway, our type system can't prove PEM, or DNE, or any of a variety of other equivalent statements, like **[Peirce's law](https://en.wikipedia.org/wiki/Peirce%2527s_law)** (`peirce : ((p -> q) -> p) -> p`) or the **[consensus theorem](https://en.wikipedia.org/wiki/Consensus_theorem)** (`consensus : (q, r) -> Either (p, q) (p -> Void, r)`). On the other hand, it *is* possible to prove the double negation of any of them, or indeed of any classically valid proposition.<sup><a id="fnr.5" class="footref" href="#fn.5">5</a></sup> Here, for instance, is the proof of the double negation of Peirce's law:

{% highlight nil %}
peirceDN : ((((p -> q) -> p) -> p) -> Void) -> Void
peirceDN f = f (\g => g (\x => void (f (\h => x))))
{% endhighlight %}

It's also possible to prove any of those statements given (an instance of) another. For instance, here's a proof DNE implies PEM (taking PEM itself for *p* in DNE):

{% highlight nil %}
dne2pem : ((((Either p (p -> Void)) -> Void) -> Void) -> (Either p (p -> Void))) -> Either p (p -> Void)
dne2pem f = f (\g => g (Right (\x => g (Left x))))
{% endhighlight %}


# Exercises

1.  Prove the double negations of PEM, DNE, and the consensus theorem.
2.  Prove that PEM, DNE, Peirce's law, and the consensus theorem are equivalent. DNE -> PEM is already done, so there are eleven more implications to prove. Or you could prove them in a circle if that's too much work.
3.  Prove [contraposition](https://en.wikipedia.org/wiki/Contraposition) (`contraposition : (p -> q) -> (q -> Void) -> p -> Void`). Can you prove its converse?


# Discussion Questions

1.  To what extent should nonconstructive reasoning be accepted?
2.  Does any of this types-as-propositions stuff have any bearing on writing real programs in the real world? Does it have any bearing on proving new theorems?


# Further Reading

-   *[The Little Typer](http://thelittletyper.com/)*
-   ["Propositions as Types"](https://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-types/propositions-as-types.pdf)
-   ["Intuitionistic Logic"](https://pdfs.semanticscholar.org/1e75/6d625d4cf2d91f69149b3d5a1f2d07fe4b2f.pdf)

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> In Idris, `Void` is a type with no constructors. It therefore has no instances, and is said to "uninhabited".

<sup><a id="fn.2" href="#fnr.2">2</a></sup> Some sources make it sound like use *p → ⊥* for *¬ p* was an innovation of intuitionism, but *p → ⊥ .↔ ¬ p* is classically valid.

<sup><a id="fn.3" href="#fnr.3">3</a></sup> The name comes from *intuitionism*, a philosophy that has something to do with mathematics stemming from mental activity. Personally I could do without that historical baggage. *Constructive logic* would be a less loaded name, but I think it might already be used for something else.

<sup><a id="fn.4" href="#fnr.4">4</a></sup> Specifically, this means stipulating that a proof of a disjunction requires a proof of one of its disjuncts.

<sup><a id="fn.5" href="#fnr.5">5</a></sup> Classical logic proves all the theorems of intuitionistic logic and then some, so in one sense classical is the stronger logic. But since any classical theorem can be proved intuitionistically by adding a double negation, we might say that intuitionistic is the stronger logic. After all, if a theorem can't be proved intuitionistically except with a double negation, then we know it doesn't have a constructive proof.
