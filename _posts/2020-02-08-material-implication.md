---
title: "Material Implication is Not Paradoxical"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-02-08 Sat&gt;</span></span>
layout: post
categories:
tags:
---
In **logic**, the so-called **"material conditional"** or "material implication" is a non-commutative truth-functional operator of two arguments that comes out false when its first argument is true and its second argument is false, and true otherwise. The "true otherwise" clause leads to situations that might seem [**"paradoxical"**](https://legacy.earlham.edu/~peters/courses/log/mat-imp.htm). In particular, it is considered strange that the conditional should be counted as true when its first argument is false and its second argument is true, as in "If the moon is made of cheese, then the sky is blue."

These "paradoxical" cases invariably deal with sentences that don't otherwise have anything to do with logic. Things become clearer with an example from **math**.

Suppose I prove a **famous conjecture**, `FC`, assuming a **plausible hypothesis**, `PH`, and that neither `FC` nor `PH` has been proved independently, and that my proof is perfectly good as far as anyone can tell. My theorem has the form `PH -> FC`, and that statement is true. This kind of thing happens all the time in math.

My theorem can be used productively in two ways.

1.  If `PH` can be proved, then `FC` will also be proved. This is *modus ponens*: from `PH -> FC` and `PH`, infer `FC`.
2.  If `FC` can be disproved, then `PH` will also be disproved. This is *modus tollens*: from `PH -> FC` and `!FC`, infer `!PH`.

Now, suppose someone comes along and proves `FC` without any assumptions. What happens to my theorem? **It was true before, but now what? Has it become false, or undefined, or something else?** No. Although it is now irrelevant, it is still perfectly true. It's still the case that `FC` can be proved assuming `PH`. In fact, `FC` can be proved with any assumption at all, including a false one &#x2013; just make the assumption and then never use it in the proof. (Make sure you don't conclude `PH` from `PH -> FC` and `FC`; that would be *affirming the consequent*, and it's a **stupid thing to do**.)

On the other hand, suppose someone comes along and disproves `PH`. Again, what happens to my theorem `PH -> FC`? Again, it's still true. In fact, it has an even simpler proof now, one that doesn't rely on the specifics of either PH or FC: `!PH` is true, so `!PH or FC` is tautologically true, whence by assumption of `PH`, `FC`.

**The purpose of logic is ultimately to figure out what follows from what**, and the material conditional aids this by linking statements together in a meaningful way so that **new knowledge can be deduced from existing knowledge**. The confusion and dismay surrounding the material conditional (that is, the "paradoxes") stem from taking a statement that is obviously true or obviously false, sticking it into a conditional with an unrelated statement, and then marveling at the result's weirdness or irrelevance or whatever. But that's putting the cart before the horse.


# Discussion Questions

1.  In **computational complexity theory**, **Ladner's theorem** says that if P != NP, then there are NP-intermediate problems, i.e. problems that are in NP and outside of P but are not NP-complete. Suppose it is discovered that P = NP after all. What happens to Ladner's theorem? Does it become false? Does it become undefined? Does it remain true? Or what? What about if an NP-intermediate problem is discovered independently?

2.  Many, perhaps even most, results in computational complexity theory take a form similar to Ladner's theorem: "Assuming such-and-such complexity classes are distinct, blah blah blah." What if it turns out that those classes mostly weren't distinct after all? Will the whole field of computational complexity theory turn out to have been **bunk** all along?

3.  When dealing with symbolic logic, statements of the form `P -> Q` are sometimes read aloud as "P *implies* Q". The logician **Quine** (after whom *quine* programs were named) used to object to this practice. He said that `P -> Q` ought to be read as "If P then Q", "P only if Q", "Q if P", etc, while the statement "P implies Q" ought to be understood to mean "the statement `P -> Q` is a tautology"; or in brief, that the word "implies" belongs to the **metalanguage**, not to the **object language**. Is this an important distinction to make, or is it pointless philosophical bikeshedding?
