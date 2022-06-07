---
title: "Binary Relations in Idris"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-11-17 Wed&gt;</span></span>
layout: post
categories:
tags:
---
Every **natural number** is either zero or the successor of some number. In **Idris** this is expressed as a **type**:

{% highlight idris %}
data Nat = Z | S Nat
{% endhighlight %}

Given two numbers *m* and *n*, ***m ≤ n*** (that is, *m* is less than or equal to *n*) either when *m* is zero or when *m* is the successor of *j* and *n* is the successor of *k* and *j ≤ k*. This is again expressed in Idris as a type:

{% highlight idris %}
data LTE  : (m, n : Nat) -> Type where
  LTEZero : LTE Z n
  LTESucc : LTE j k -> LTE (S j) (S k)
{% endhighlight %}

≤ is the classic example of a **binary relation**. In type theory a binary relation is a function of type `ty -> ty -> Type`. This is not to be confused with **binary operation**, which is a function of type `ty -> ty -> ty`. Binary operations produce instances of some type, but binary relations produce things that are themselves types. In spirit a binary relation is similar to a function of type `ty -> ty -> Bool`; it is a **proposition** that "says" something that may or may not be true.

Certain common properties are used to classify binary relations and describe their behavior. For example, ≤ is **reflexive**: *x ≤ x* for all *x*. It is also **transitive** and **antisymmetric**: if *x ≤ y* and *y ≤ z* then *x ≤ z*; and *x ≤ y* and *y ≤ x* only when *x = y*.

In idris these properties are expressed with **interfaces**:

{% highlight idris %}
interface Reflexive ty rel where
  reflexive : {x : ty} -> rel x x

interface Transitive ty rel where
  transitive : {x, y, z : ty} -> rel x y -> rel y z -> rel x z

interface Antisymmetric ty rel where
  antisymmetric : {x, y : ty} -> rel x y -> rel y x -> x = y
{% endhighlight %}

Implementing these interfaces for a relation over some type **verifies** that the relation bears those properties. Sometimes this is difficult, and sometimes it's easy:

{% highlight idris %}
Reflexive Nat LTE where
  reflexive {x = Z} = LTEZero
  reflexive {x = S k} = LTESucc $ reflexive {x = k}

Transitive Nat LTE where
  transitive LTEZero _ = LTEZero
  transitive (LTESucc xy) (LTESucc yz) =
    LTESucc $ transitive {rel = LTE} xy yz

Antisymmetric Nat LTE where
  antisymmetric LTEZero LTEZero = Refl
  antisymmetric (LTESucc xy) (LTESucc yx) =
    cong S $ antisymmetric xy yx
{% endhighlight %}

A **preorder** is a relation that is both reflexive and transitive, and a **partial order** is a preorder that is antisymmetric:

{% highlight idris %}
interface (Reflexive ty rel, Transitive ty rel) => Preorder ty rel where

interface (Preorder ty rel, Antisymmetric ty rel) => PartialOrder ty rel where
{% endhighlight %}

These order properties are **empty** &#x2013; just definitions that **bundle together other properties**. Consequently they are easy to implement:

{% highlight idris %}
Preorder Nat LTE where

PartialOrder Nat LTE where
{% endhighlight %}

A slightly more complicated property is *connexity*. A relation is **connex** over a type if any two distinct instances of the type are related one way or another, and a **linear order** is a connex partial order:

{% highlight idris %}
interface Connex ty rel where
  connex : {x, y : ty} -> Not (x = y) -> Either (rel x y) (rel y x)

interface (PartialOrder ty rel, Connex ty rel) => LinearOrder ty rel where
{% endhighlight %}

≤ is connex over the naturals, but this is **trickier to prove** than the other properties:

{% highlight idris %}
Connex Nat LTE where
  connex {x = Z} _ = Left LTEZero
  connex {y = Z} _ = Right LTEZero
  connex {x = S _} {y = S _} prf =
    case connex {rel = LTE} $ prf . (cong S) of
      Left jk => Left $ LTESucc jk
      Right kj => Right $ LTESucc kj

LinearOrder Nat LTE where
{% endhighlight %}

≤ is antisymmetric: *x ≤ y* implies *y ≤ x* only when *y = x*. A relation is **symmetric** when it goes both ways unconditionally:

{% highlight idris %}
interface Symmetric ty rel where
  symmetric : {x, y : ty} -> rel x y -> rel y x
{% endhighlight %}

A simple example of a symmetric relation is the relation of **being-within-one-of**:

{% highlight idris %}
WithinOneOf : (a, b : Nat) -> Type
WithinOneOf a b = Either (a = b) $ Either (a = S b) (b = S a)
{% endhighlight %}

If *x* is within one of *y*, then *y* is within one of *x*. Further, *x* is within one of *x* for all *x*:

{% highlight idris %}
Reflexive Nat WithinOneOf where
  reflexive = Left Refl

Symmetric Nat WithinOneOf where
  symmetric (Left x_eq_y) = Left $ sym x_eq_y
  symmetric (Right $  Left prf) = Right $ Right prf
  symmetric (Right $ Right prf) = Right $  Left prf
{% endhighlight %}

A relation that is both reflexive and symmetric is a **tolerance relation**:

{% highlight idris %}
interface (Reflexive ty rel, Symmetric ty rel) => Tolerance ty rel where

Tolerance Nat WithinOneOf where
{% endhighlight %}

The within-one-of relation is not transitive. 2 is within one of 3 and 4 is within one of 3, but 2 is not within one of 4. A tolerance relation that is transitive is an **equivalence relation**. This could also be defined as a symmetric preorder. Or even better, forget about the **hierarchy** altogether and define an equivalence relation directly as a bundle of reflexive, transitive, and symmetric:

{% highlight idris %}
interface (Reflexive ty rel, Transitive ty rel, Symmetric ty rel) => Equivalence ty rel where

Equivalence ty rel => Preorder ty rel where

Equivalence ty rel => Tolerance ty rel where
{% endhighlight %}

Let *p* be a **factor** of *q* and let *q* be factor of *r*. Is *p* a factor of *r*? Yes, and therefore the is-a-factor-of relation is transitive. It's also reflexive and antisymmetric, and so the relation is another example of a partial order. All of these claims can be proved in Idris, although it **takes some work**:

{% highlight idris %}
data Factor : Nat -> Nat -> Type where
    CofactorExists : {p, n : Nat} -> (q : Nat) -> n = p * q -> Factor p n

Reflexive Nat Factor where
  reflexive = CofactorExists 1 $ rewrite multOneRightNeutral x in Refl

Transitive Nat Factor where
  transitive (CofactorExists qb prfAB) (CofactorExists qc prfBC) =
    CofactorExists (qb * qc) $
        rewrite prfBC in
        rewrite prfAB in
        rewrite multAssociative x qb qc in
        Refl

Preorder Nat Factor where

-- Proofs elided because they are boring and complicated...
multOneSoleNeutral : (a, b : Nat) -> S a = S a * b -> b = 1
oneSoleFactorOfOne : (a : Nat) -> Factor a 1 -> a = 1

Antisymmetric Nat Factor where
  antisymmetric {x = Z} (CofactorExists _ prfAB) _ = sym prfAB
  antisymmetric {y = Z} _ (CofactorExists _ prfBA) = prfBA
  antisymmetric {x = S a} {y = S _} (CofactorExists qa prfAB) (CofactorExists qb prfBA) =
      let qIs1 = multOneSoleNeutral a (qa * qb) $
              rewrite multAssociative (S a) qa qb in
              rewrite sym prfAB in
              prfBA
      in
      rewrite prfAB in
      rewrite oneSoleFactorOfOne qa . CofactorExists qb $ sym qIs1 in
      rewrite multOneRightNeutral a in
      Refl

PartialOrder Nat Factor where
{% endhighlight %}

Reflexivity, transitivity, and symmetry are the most prominent properties of binary relations. A lesser-known property is *density*: a relation is **dense** if between any two related elements there is a third related element:

{% highlight idris %}
interface Dense ty rel where
  dense : {x, y : ty} -> rel x y -> (z : ty ** (rel x z, rel z y))
{% endhighlight %}

**Every reflexive relation is dense**: if *x* is related to *y*, then by reflexivity *x* is related to *x*, and so *x* itself serves as the intercalated element:

{% highlight idris %}
Reflexive ty rel => Dense ty rel where
  dense {x} xy = (x ** (reflexive {x}, xy))
{% endhighlight %}

So ≤ is technically dense, but that doesn't mean much. The strictly-less-than relation **<** is not dense over the natural numbers: *3 < 4*, but there is no *x* such that *3 < x* and *x < 4*. But it is dense over the **rational numbers**: if *a/b < c/d*, then *a+c/b+d* comes between them.

A relation such that *x* being related to *y* and also to *z* implies that *y* is related to *z* is called **Euclidean**:

{% highlight idris %}
interface Euclidean ty rel where
  euclidean : {x, y, z : ty} -> rel x y -> rel x z -> rel y z
{% endhighlight %}

Euclideanness is commonly listed as a property of relations, but **examples are hard to come by**. The [Wikipedia page for Euclidean relations](https://en.wikipedia.org/wiki/Euclidean_relation) doesn't list any! Still, a few general properties can be proved. If a Euclidean relation is reflexive, it is also symmetric; and if it is reflexive, it is also transitive. Finally, a relation that is both transitive and symmetric is Euclidean:

{% highlight idris %}
[RES] (Reflexive ty rel, Euclidean ty rel) => Symmetric ty rel where
  symmetric {x} xy =
    euclidean {x} xy $ reflexive {x}

[RET] (Reflexive ty rel, Euclidean ty rel) =>
      Transitive ty rel using RES where
  transitive {rel} xy yz =
    symmetric {rel} $ euclidean {rel} yz $ symmetric {rel} xy

[TSE] (Transitive ty rel, Symmetric ty rel) => Euclidean ty rel where
  euclidean {rel} xy xz =
    transitive {rel} (symmetric {rel} xy) xz
{% endhighlight %}

As of **v0.5**, all of these relations and more are included in the **[Idris 2 standard library](https://github.com/idris-lang/Idris2/blob/main/libs/base/Control/Relation.idr)**. I authored the current design. Earlier version of Idris used a different relation module with fewer relations and an inflexible hierarchy of order relations.
