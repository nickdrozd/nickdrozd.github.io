---
title: "A Better Turing Machine Tape Model"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-12-31 Fri&gt;</span></span>
layout: post
categories:
tags:
---
A **Turing machine** is a simple type of computer. Its memory consists of a single strip of **tape** that is divided into discrete **cells**, each one of which is marked with one of a fixed number of **colors**. Data is read from and written to the tape by means of a **tape head**. Turing machine memory is not random-access; the machine head can reach any cell on the tape, but it must move cell by cell to get there. At any given time the tape head is scanning just one cell.

![img](/assets/2021-12-31-turing-machine-tape/bbj-tm.png)

On each **machine cycle** the following **tape operations** are executed:

1.  The current cell is read.
2.  A new color is optionally printed to the current cell.
3.  The tape head shifts one cell either to the left or the right.

The color printed in step 2 and the direction shifted in step 3 are determined by a combination of the color read from step 1 and the current "state" of the machine. This machine state is otherwise irrelevant to the tape.

The Turing machine's tape is sometimes described as being **"infinite in both directions"**. There are people who get spooked by the word "infinite", and they will object that Turing machines are **"not physically realizable"** or even that they are **"meaningless"**. Ironically, objections of this sort crop up endlessly. To avoid dull and tiresome philosophical diatribes, it is good enough for theoretical purposes to say that the tape is sufficiently long for any computation that needs to be done, or that **there is plenty of tape to go around**.

Suppose we are interested in writing a **simulator** for a Turing machine. **How should the tape be represented?** The sequence of tape operations just described suggests a **tape interface**:

{% highlight haskell %}
Color : Type
Color = Nat

data Shift = L | R

interface
Tape tape where
  read  :  tape -> Color
  print : Color -> tape -> tape
  shift : Shift -> tape -> tape
{% endhighlight %}

This interface prescribes the operations that any tape representation needs to implement. But what about the tape type itself? What does it look like? The obvious way to represent the tape is to use an **array** of some kind (vector, list, tuple, whatever), with the position of the tape head represented by an **index pointer** into the array.

{% highlight haskell %}
PointerTape : Type
PointerTape = (i : Nat ** (Fin (S i), Vect (S i) Color))
{% endhighlight %}

Now, an array is of finite length, but the Turing machine tape is of infinite / unbounded / unspecified length. An array can be made to be "plenty long" by using a technique called **dynamic tape allocation**. If the array pointer (representing the tape head) reaches either end of the array (the tape), new cells are simply added to the array. From the point of view of the tape head, it will appear as if there are infinitely many cells. With this strategy in mind, the `Tape` interface can be implemented for `PointerTape`:

{% highlight haskell %}
implementation
Tape PointerTape where
  read    (_ ** (pos, tape)) =
    index pos tape

  print c (i ** (pos, tape)) =
    (i ** (pos, replaceAt pos c tape))

  shift L (i ** (  FZ, tape)) = (S i ** (FZ, [0] ++ tape))
  shift L (i ** (FS p, tape)) = (  i ** ( weaken p, tape))

  shift R (i ** (pos, tape)) =
    case strengthen pos of
      Just inc => (  i ** (FS inc, tape))
      Nothing  =>
        let prf = sym $ plusCommutative i 1 in
          (S i ** (FS pos, rewrite prf in tape ++ [0]))
{% endhighlight %}

The details will vary among languages, but this ***pointer model*** is the most common way to represent the Turing machine tape.

There are three problems with this model.

1.  **The meaning of the tape depends on a pointer external to it.** The cells of the tape are represented with an array, but the full situation of the tape cannot be understood until the pointer is applied to the array. The color of the current cell is read on every single machine cycle, and that means that on every single machine cycle the context of the tape must be reestablished through pointer indexing.

2.  **The value of array pointer is a critical implementation detail, but it has no meaning in terms of the Turing machine tape it models.** Array indices are counted from the left, and so for array index *x* and tape length *L* we have either *0 ≤ x < L* or *0 < x ≤ L*. But this number is meaningless for the tape itself. If anything, the value of the index ought to be an integer with value 0 at the starting square and negative values to the left and positive values to the right. This can actually be effected in **Python** through the "magic methods" `__getitem__` and `__setitem__`, but in most cases left-to-right counting is the order of the day.

3.  **The left and right shift operations are handled differently.** Dynamic tape allocation requires checking array bounds, and array bounds for the left and right sides are always handled differently. ***Off-by-one errors are unavoidable.*** (This problem is related to but distinct from the previous issue.)

One prominent feature of the pointer model is that **tape cells are treated uniformly**. All the cells sit there together in one single array. One of these cells is the one currently scanned by the tape head, but it isn't marked as such, remaining unknown until the array index is applied.

**Abandoning cell uniformity solves all the problems of the pointer model.** Instead of a single cell array, three portions of the tape are explicitly distinguished: the cell currently scanned, the span of cells to the left of the scanned cell, and the span of cells to the right of the scanned cell.

Thus, the **Scan 'n' Span model**:

{% highlight haskell %}
ScanNSpan : Type -> Type
ScanNSpan span = (span, Color, span)
{% endhighlight %}

In this model, **the relationship between the tape and the tape head is reversed.** In the pointer model, the tape is imagined to be fixed in place, with the tape head shifting back and forth along the tape. Here, it's instead the tape head that is imagined to be fixed in place. Rather than moving, the tape head pushes the scanned cell into the one span and pulls the next cell from the other. (The spans here are really **stacks**, and this model might also be called the *two-stack model*.)

Leaving things abstract for a moment, here's an interface to describe how the spans are expected to behave:

{% highlight haskell %}
interface
Spannable span where
  pull : span -> (Color, span)
  push : Color -> span -> span
{% endhighlight %}

The most obvious way to implement a span is with a list. But a **list of what?** For the moment this question doesn't need to be answered &#x2013; it is enough to know that the list unit is spannable:

{% highlight haskell %}
implementation
Spannable (List unit) => Tape (ScanNSpan (List unit)) where
  read    (_, c, _) = c

  print c (l, _, r) = (l, c, r)

  shift L (l, c, r) =
    let (x, n) = pull l in
      (n, x, push c r)

  shift R (l, c, r) =
    let (x, n) = pull r in
      (push c l, x, n)
{% endhighlight %}

All that's left to get a concrete representation is to determine a unit type and then implement `Spannable` for `List unit`. A perfectly good way to do this is to use a list of individual cells:

{% highlight haskell %}
implementation
Spannable (List Color) where
  pull []        = (0, [])
  pull (c :: cs) = (c, cs)

  push c cs = c :: cs

SnSColor : Type
SnSColor = ScanNSpan $ List Color
{% endhighlight %}

And that's it! The Scan 'n' Span model is **dramatically simpler** than the pointer model. As an added bonus, it's also **way faster** on account of not needing to bother with constant array-indexing and bounds-checking.

It's common for Turing machine programs to leave long stretches of the tape with the same color. The memory for the tape representation can be reduced by using **run-length encoding**, with the repeated cells of the same color represented by a single cell with a color and an **exponent**:

{% highlight haskell %}
Block : Type
Block = (Color, Nat)
{% endhighlight %}

Again, it is easy to get a concrete tape representation by implementing `Spannable` for `List Block`:

{% highlight haskell %}
implementation
Spannable (List Block) where
  pull [] = (0, [])

  pull ((c, n) :: bs) =
    (c, case n of
             (S $ S k) => (c, S k) :: bs
             _         => bs)

  push c [] = [(c, 1)]

  push c span@((k, n) :: bs) =
    if c == k
      then (c, 1 + n) :: bs
      else (c, 1    ) :: span

SnsBlockTape : Type
SnsBlockTape = ScanNSpan $ List Block
{% endhighlight %}


# Exercises

1.  Modify the `Tape` interface so that the `print` and `shift` are combined into a single operation and update the implementations accordingly.

2.  Instead of a list, a single number can be used as a span. Implement `Tape (ScanNSpan Nat)`. (Hint: this amounts to a sort of Gödel numbering.)
