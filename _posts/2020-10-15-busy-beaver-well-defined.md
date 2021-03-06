---
title: "Is the Busy Beaver Sequence Well-Defined?"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-10-15 Thu&gt;</span></span>
layout: post
categories:
tags:
---
The nth **Busy Beaver number** is defined as the longest runtime of all **halting Turing machines** of *n* states. Is this sequence **well-defined**? For concreteness, let's consider a number to be well-defined if it would be accepted as a valid entry in the **[Bigger Number Game](https://www.scottaaronson.com/writings/bignumbers.html)** (BNG):

> You have fifteen seconds. Using standard math notation, English words, or both, name a single whole number — not an infinity — on a blank index card. Be precise enough for any reasonable modern mathematician to determine exactly what number you've named, by consulting only your card and, if necessary, the published literature.

One caveat that might be added here is **"in principle"**. A real-life human mathematician only lives so long and only has a brain that is so big and can only comprehend numbers up to a certain point. But these are just **resource constraints**, and that's not in the spirit of BNG. What we really want are the biggest numbers that can be named given **unlimited resources**. Anything at all that's needed to determine a number &#x2013; time, space, coffee, whatever &#x2013; is assumed to be available. **From here on out, all talk of determining numbers will be "in principle".**

Okay, we're playing BNG, and I write down **"BB(5) (the fifth Busy Beaver number)"**. Is that a valid entry? Here's a straightforward argument that it is:

1.  There are finitely many 5-state Turing machine programs. Consider the set of all of them.
2.  Every program, when run on the blank tape, **either halts or not**. Consider the finite subset consisting of just those that halt.
3.  Every halting program halts after some number of steps. Consider the finite set of all those numbers.
4.  Every finite set of numbers has a maximum, and the maximum of the set under consideration is the number named by the expression "BB(5)". QED.

Steps 1, 3, and 4 are beyond reproach, but step 2 is **tricky**. It relies on the **Principle of the Excluded Middle** (PEM), which says that for any proposition *P*, either *P* is true or its negation is. The specific instance of *P* in this case is *M halts* for an arbitrary machine *M*. Is it reasonable to believe of an arbitrary machine that it definitely halts or does not halt? Is it reasonable to consider a set to be "well-defined" solely on the basis of such a proposition?

**[Tibor Rado](http://computation4cognitivescientists.weebly.com/uploads/6/2/8/3/6283774/rado-on_non-computable_functions.pdf)** thought so; he described sets such as the one in step 2 as "exceptionally well-defined". I don't want to harp on a passing turn of phrase, but adding an **adverb** to a **Boolean-valued predicate** like "well-defined" makes me suspicious. *"These numbers are so well-defined&#x2026;you've never seen such well-defined numbers! So many mathematicans are saying, all the best mathematicians have been telling me that they can't believe how well-defined these numbers are! They've never seen anything like it!"* Okay, maybe it isn't quite that bad, but still.

Anyway, put that issue aside for a moment and consider a different BNG entry: **"1 if Goldbach's Conjecture (GC) is false"**. Is that expression sufficiently specified to uniquely designate some number? Probably not. If I submitted that as my entry, I would expect it to be rejected, since it doesn't define a value if GC is true.

What if I amend it to cover that case? **"1 if GC is false, else 0"**. According to PEM, GC is either true or false, so clearly this expression designates **some number or other**. But which one? Does it designate 1 or does it designate 0?

That's not so clear, but either way it's not a very good BNG entry. If my opponent submits any number that is at least 2, I will lose, regardless of the truth of GC. To increase my chances of victory, I once again modify my entry: **"The least counterexample to GC if there is one, else 0"**. My opponent submits "1895 (the year of Tibor Rado's birth)". Who wins? According to [Wikipedia](https://en.wikipedia.org/wiki/Goldbach%27s_conjecture), GC has been verified up to 4 x 10<sup>18</sup>, so I will win if GC is false, and otherwise I will lose.

**When I write "BB(5)", what number exactly am I naming?** It's known that BB(5) ≥ 47176870, as witnessed by the program `1RB 1LC 1RC 1RB 1RD 0LE 1LA 1LD 1RH 0LA`. **That fact is not in dispute**, and it can be verified by anybody. It's so certain that it can be used to validate a Turing machine simulator; if you run your simulator on that program and come up with a runtime other than 47176870, you've screwed up, and that's that. I want to make it clear that I am not pushing **relativism** or **observer-dependent truth** or any junk like that. There are indeed some universally agreed-upon, no-doubt-about-it facts of the matter.

The **halting problem** is famously **undecidable**, but it's also **semidecidable**: for any program that really does halt, it can be verfied with certainty that that is the case. It's those *other* programs, the non-halting ones, that cause trouble. Almost all five-state programs have been determined to either halt or not, but there are a handful of holdouts. They are conjectured not to halt, but that has not been proved.

Suppose that instead of "BB(5)", I submit this entry instead: **"The longest runtime of any of the five-state holdout programs if any of them halt, else 47176870"**. Is that any more well-defined than the GC entry? Is it any different from writing "BB(5)"? Is the instance of PEM that says of an arbitrary program that it halts or not any more or less plausible than the instance of PEM that says GC is true or not?

PEM is clearly doing a lot of work here. In its general form, it's actually a somewhat **extreme** axiom schema. Although it doesn't commit to the truth or falsity of any particular statement, it does commit to one or the other for every statement. One consequence of PEM is that the **Continuum Hypothesis** is true or false. Is that self-evidently true?

One way to limit exposure to the dicier consequences of PEM is to **admit only some of its instances**. **[Scott Aaronson](https://www.scottaaronson.com/blog/?p=327)** has proposed one way of choosing which ones to keep:

> I submit that the key distinction is between
>
> 1.  questions that are ultimately about Turing machines and finite sets of integers (even if they're not phrased that way), and
>
> 2.  questions that aren't.
>
> We need to assume that we have a "direct intuition" about integers and finite processes, which precedes formal reasoning — since without such an intuition, we couldn't even do formal reasoning in the first place.

Objects are partitioned into two classes according as whether or not they can be understood and reasoned about without relying on a formal theory. Call these classes ***integer-like*** and ***non-interger-like***. This seems like something that would be difficult to make precise. Unfortunately, **I agree with the spirit of the partition, but not its details**, so a formal argument might be required. It's hard to be precise once you've hit bedrock though, so hopefully an intuitive argument will suffice.

Aaronson gives four examples of integer-like objects: **integers**, **finite sets of integers**, **finite processes**, and **Turing machines**. Integers and finite sets of integers are obviously integer-like, so they can be ignored. This leaves "Turing machines" and "finite processes".

I'm going to make a few assumptions. 1) The "processes" discussed here are **"computational processes"**. The word "computational" is not intended to be conceptually load-bearing. 2) **Some processes are finite, and some are not.** 3) Turing machines are really just a stand-in for the concept of "program", so without gain of generality we can simply discuss programs.

It's agreed that finite computational processes are integer-like, and I suppose it's also agreed that infinite computational processes are non-integer-like. That leaves one last question: **are programs integer-like**? In some sense, a program might be considered as nothing more than a **blob of text**, and blobs of text are obviously integer-like. This is about as accurate as saying that humans are nothing more bags of meat. It's true as far as it goes, but it leaves out something important.

**A program is a description of a computational process**. Whether this is true by definition or a meaningful philosophical statement is a matter of perspective. There's no way to make things precise here, so I'll settle for quoting from ***[The Structure and Interpretation of Computer Programs](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-9.html#%_chap_1)***:

> Computational processes are abstract beings that inhabit computers&#x2026;People create programs to direct processes. In effect, we conjure the spirits of the computer with our spells. A computational process is indeed much like a sorcerer's idea of a spirit. It cannot be seen or touched. It is not composed of matter at all. However, it is very real&#x2026;The programs we use to conjure processes are like a sorcerer's spells. They are carefully composed from symbolic expressions in arcane and esoteric "programming languages" that prescribe the tasks we want our processes to perform.

The **Church-Turing thesis** says the converse: **every computational process is described by some program or other**. Some computational processes are infinite; therefore **some programs are descriptions of infinite processes**. Are such programs integer-like?

That might seem like a crucial question, but it isn't. The real issue is that **there's no way to tell which programs describe finite processes and which ones describe infinite processes**. Aaronson gives some examples of processes:

> It's easy to imagine a "physical process" whose outcome could depend on whether Goldbach's Conjecture is true or false. (For example, a computer program that tests even numbers successively and halts if it finds one that's not a sum of two primes.)&#x2026; But can you imagine a "physical process" whose outcome could depend on whether there's a set larger than the set of integers but smaller than the set of real numbers? If so, what would it look like?

"A computer program that tests even numbers successively and halts if it finds one that's not a sum of two primes". This is an informal but nevertheless complete description of a program, and that program is a description of a computational process. Is the process described finite or infinite? Well, at present the best that can be said is that **the process is finite if GC is false, else infinite**.

We have this distinction between integer-like objects and non-integer-like objects. What should be done with programs like the one above? Put them in a **"maybe" pile**? I don't know, but I don't think it's safe or reasonable to call such a program integer-like. *The very process that determines whether or not an object is integer-like is not itself integer-like*.

***"Quit talking in circles and get to the point. Is the Busy Beaver sequence well-defined or not?"***

Neither! I don't think it's well-defined (at least not by the lights of BNG), but I also don't think it's not well-defined. I would say it's **not *not* well-defined**, but that's as far as I'll go.
