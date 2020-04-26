---
title: "Idris Algebra"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-04-26 Sun&gt;</span></span>
layout: post
categories:
tags:
---
A **semigroup** is a set equipped with a binary operation that is **associative**. This operation is usually called "addition", though it may actually be something else. In **Idris**, this can expressed with an interface<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>:

{% highlight idris %}
interface Semigroup t where
  (<+>) : t -> t -> t

  semigroupOpIsAssociative : (l, c, r : t) ->
    l <+> (c <+> r) = (l <+> c) <+> r
{% endhighlight %}

A **monoid** is a semigroup with a **neutral** element, an element that doesn't change another element when "added" to it:

{% highlight idris %}
interface Semigroup t => Monoid t where
  neutral : t

  monoidNeutralIsNeutralL : (l : t) -> l <+> neutral = l
  monoidNeutralIsNeutralR : (r : t) -> neutral <+> r = r
{% endhighlight %}

The **inverse** of an element `x` is an element `x'` such that `x <+> x' = neutral`. It can be proved that in a monoid, an element can only have one inverse:

{% highlight idris %}
uniqueInverse : Monoid t => (x, y, z : t) ->
  y <+> x = neutral -> x <+> z = neutral -> y = z
uniqueInverse x y z p q =
  rewrite sym $ monoidNeutralIsNeutralL y in
    rewrite sym q in
      rewrite semigroupOpIsAssociative y x z in
  rewrite p in
    rewrite monoidNeutralIsNeutralR z in
      Refl
{% endhighlight %}

Informally, this proof says:

-   `y`
-   `= y + 0`
-   `= y + (x + z)`
-   `= (y + x) + z`
-   `= 0 + z`
-   `= z`

A **group** is a monoid in which every element has an inverse:

{% highlight idris %}
interface Monoid t => Group t where
  inverse : t -> t

  groupInverseIsInverseR : (r : t) -> inverse r <+> r = neutral
{% endhighlight %}

In this definition, only a **right inverse** is required. Some definitions also call for a **left inverse**, but the existence of a left inverse can instead be derived with a little effort:

{% highlight idris %}
selfSquareId : Group t => (x : t) ->
  x <+> x = x -> x = neutral
selfSquareId x p =
  rewrite sym $ monoidNeutralIsNeutralR x in
    rewrite sym $ groupInverseIsInverseR x in
  rewrite sym $ semigroupOpIsAssociative (inverse x) x x in
    rewrite p in
      Refl

inverseCommute : Group t => (x, y : t) ->
  y <+> x = neutral -> x <+> y = neutral
inverseCommute x y p = selfSquareId (x <+> y) prop where
  prop : (x <+> y) <+> (x <+> y) = x <+> y
  prop =
    rewrite sym $ semigroupOpIsAssociative x y (x <+> y) in
      rewrite semigroupOpIsAssociative y x y in
    rewrite p in
      rewrite monoidNeutralIsNeutralR y in
        Refl

groupInverseIsInverseL : Group t => (x : t) ->
  x <+> inverse x = neutral
groupInverseIsInverseL x =
  inverseCommute x (inverse x) (groupInverseIsInverseR x)
{% endhighlight %}

In a group, the **inverse of the inverse** of an element is just that element, or more briefly, `-(-x) = x`. This is a consquence of the **unique inverse theorem**, since `x` and `-(-x)` are both inverses of `-x`:

{% highlight idris %}
inverseSquaredIsIdentity : Group t => (x : t) ->
  inverse (inverse x) = x
inverseSquaredIsIdentity x =
  let x' = inverse x in
    uniqueInverse
      x'
      (inverse x')
      x
      (groupInverseIsInverseR x')
      (groupInverseIsInverseR x)
{% endhighlight %}

The **Latin square property** says that for any two elements `a, b` in a group, there exist `x, y` such that `a + x = b` and `y + a = b` have solutions (unique ones, in fact):

{% highlight idris %}
latinSquareProperty : Group t => (a, b : t) ->
  ((x : t ** a <+> x = b),
    (y : t ** y <+> a = b))
latinSquareProperty a b =
  let a' = inverse a in
    (((a' <+> b) **
      rewrite semigroupOpIsAssociative a a' b in
        rewrite groupInverseIsInverseL a in
          monoidNeutralIsNeutralR b),
    (b <+> a' **
      rewrite sym $ semigroupOpIsAssociative b a' a in
        rewrite groupInverseIsInverseR a in
          monoidNeutralIsNeutralL b))
{% endhighlight %}

An **abelian group** is a group in which the operation is **commutative**:

{% highlight idris %}
interface Group t => AbelianGroup t where
  abelianGroupOpIsCommutative : (l, r : t) -> l <+> r = r <+> l
{% endhighlight %}

A **ring** is an abelian group equipped with another operation, usually called "multiplication". This operation is associative, and it **distributes** over addition:

{% highlight idris %}
interface AbelianGroup a => Ring a where
  (<.>) : a -> a -> a

  ringOpIsAssociative   : (l, c, r : a) ->
    l <.> (c <.> r) = (l <.> c) <.> r
  ringOpIsDistributiveL : (l, c, r : a) ->
    l <.> (c <+> r) = (l <.> c) <+> (l <.> r)
  ringOpIsDistributiveR : (l, c, r : a) ->
    (l <+> c) <.> r = (l <.> r) <+> (c <.> r)
{% endhighlight %}

In a ring, **multiplying by zero** (that is, the additive identity element) results in zero:

{% highlight idris %}
multNeutralAbsorbingL : Ring t => (r : t) ->
  neutral <.> r = neutral
multNeutralAbsorbingL {t} r =
  let
    e = the t neutral
    ir = inverse r
    exr = e <.> r
    iexr = inverse exr
      in
  rewrite sym $ monoidNeutralIsNeutralR exr in
    rewrite sym $ groupInverseIsInverseR exr in
  rewrite sym $ semigroupOpIsAssociative iexr exr ((iexr <+> exr) <.> r) in
    rewrite groupInverseIsInverseR exr in
  rewrite sym $ ringOpIsDistributiveR e e r in
    rewrite monoidNeutralIsNeutralR e in
  groupInverseIsInverseR exr

multNeutralAbsorbingR : Ring t => (l : t) ->
  l <.> neutral = neutral
  -- similar to left side
{% endhighlight %}

In a ring, a **positive** times a **negative** is negative, and two negatives multiplied together are positive:

{% highlight idris %}
multInverseInversesL : Ring t => (l, r : t) ->
  inverse l <.> r = inverse (l <.> r)
multInverseInversesL l r =
  let
    il = inverse l
    lxr = l <.> r
    ilxr = il <.> r
    i_lxr = inverse lxr
      in
  rewrite sym $ monoidNeutralIsNeutralR ilxr in
    rewrite sym $ groupInverseIsInverseR lxr in
      rewrite sym $ semigroupOpIsAssociative i_lxr lxr ilxr in
  rewrite sym $ ringOpIsDistributiveR l il r in
    rewrite groupInverseIsInverseL l in
  rewrite multNeutralAbsorbingL r in
    monoidNeutralIsNeutralL i_lxr

multInverseInversesR : Ring t => (l, r : t) ->
  l <.> inverse r = inverse (l <.> r)
  -- similar to left side

multNegativeByNegativeIsPositive : Ring t => (l, r : t) ->
  inverse l <.> inverse r = l <.> r
multNegativeByNegativeIsPositive l r =
    rewrite multInverseInversesR (inverse l) r in
    rewrite sym $ multInverseInversesL (inverse l) r in
    rewrite inverseSquaredIsIdentity l in
    Refl
{% endhighlight %}

A **ring with unity** is a ring with a **multiplicative identity**, i.e. "one". Terminology is not universally agreed upon here. Some definitions require rings to have a multiplicative identity, and refer to a ring *without* unity as a **"rng"** (a ring without "i"). I think that name is funnier, but it is arguably harder to read.

{% highlight idris %}
interface Ring a => RingWithUnity a where
  unity : a

  ringWithUnityIsUnityL : (l : a) -> l <.> unity = l
  ringWithUnityIsUnityR : (r : a) -> unity <.> r = r
{% endhighlight %}

In a ring with unity, `x * -1 = -x = -1 * x`:

{% highlight idris %}
inverseOfUnityR : RingWithUnity t => (x : t) ->
  inverse unity <.> x = inverse x
inverseOfUnityR x =
  rewrite multInverseInversesL unity x in
    rewrite ringWithUnityIsUnityR x in
      Refl

inverseOfUnityL : RingWithUnity t => (x : t) ->
  x <.> inverse unity = inverse x
  -- similar to right side
{% endhighlight %}

A **commutative ring** is a ring with commutative multiplication. It doesn't need to have a unity:

{% highlight idris %}
interface Ring a => CommutativeRing a where
  ringOpIsCommutative : (x, y : a) -> x <.> y = y <.> x
{% endhighlight %}

A **field** is a commutative ring with unity whose nonzero elements have **multiplicative inverses**:

{% highlight idris %}
interface (RingWithUnity a, CommutativeRing a) => Field a where
  inverseM : (x : a) -> Not (x = neutral) -> a

  fieldInverseIsInverseR : (r : a) -> (p : Not (r = neutral)) ->
    inverseM r p <.> r = unity
{% endhighlight %}

The "nonzero" qualifier makes the multiplicative inverse operation somewhat involved: it takes as inputs **both** an element `x` **and** a **proof** that `x /= 0`. I don't yet know of a simple and ergonomic way to use it.

The proofs up to now have been fairly short. Longer proofs come into play when considering **complex numbers**. Normally complex numbers are considered as pairs of real numbers, but in general it's possible to restrict one's view to complex numbers over a particular set. In that case, complex numbers are just pairs of elements of that set:

{% highlight idris %}
data Complex t = (:+) t t
{% endhighlight %}

**Adding two complex numbers is easy**: add the real components, then add the imaginary components, then pair up the results, and that's it. It is easy to prove that complex numbers formed out of numbers that form a semigroup themselves form a semigroup:

{% highlight idris %}
Semigroup a => Semigroup (Complex a) where
  (<+>) (a :+ b) (c :+ d) = (a <+> c) :+ (b <+> d)

  semigroupOpIsAssociative (a :+ x) (b :+ y) (c :+ z) =
    rewrite semigroupOpIsAssociative a b c in
      rewrite semigroupOpIsAssociative x y z in
        Refl
{% endhighlight %}

Similar reasoning proves the same for monoids and groups.

Complex numbers over rings are much trickier, because **complex multiplication is trickier**: `(a, b) * (c, d) = (ac - bc, ad + bc)`. Multiplication and addition interact, and there are inverses.

With a lot of effort, it can be proved that the **complex numbers of elements of a ring themselves form a ring**; for example, the subset of complex numbers whose real and imaginary components are both integers. The proofs of distributivity are manageable, but the proof of associativity is real nasty. **It is one of the longest Idris proofs that I have seen.** That is partly due to inherent complexity and partly due to inelegance. It could be cleaned up and shortened.

Here are the proofs in full.

{% highlight idris %}
-- A simple helper lemma
private abelianGroupRearrange : AbelianGroup t => (a, b, c, d : t) ->
  a <+> b <+> (c <+> d) = a <+> c <+> (b <+> d)
abelianGroupRearrange a b c d =
  rewrite sym $ semigroupOpIsAssociative a b (c <+> d) in
    rewrite semigroupOpIsAssociative b c d in
      rewrite abelianGroupOpIsCommutative b c in
    rewrite sym $ semigroupOpIsAssociative c b d in
  semigroupOpIsAssociative a c (b <+> d)

Ring t => Ring (Complex t) where
  (<.>) (a :+ b) (c :+ d) = (a <.> c <-> b <.> d) :+ (a <.> d <+> b <.> c)

  ringOpIsDistributiveR (a :+ x) (b :+ y) (c :+ z) =
    -- Distribute inverses (target z)
    rewrite sym $ multInverseInversesR (x <+> y) z in
      rewrite sym $ multInverseInversesR x z in
        rewrite sym $ multInverseInversesR y z in
    -- Shuffle terms
    rewrite shuffle a b c x y (inverse z) in
      rewrite shuffle a b z x y c in
        Refl where
    shuffle : (f, g, h, i, j, k : t) ->
      (f <+> g) <.> h <+> (i <+> j) <.> k =
        f <.> h <+> i <.> k <+> (g <.> h <+> j <.> k)
    shuffle f g h i j k =
      rewrite ringOpIsDistributiveR f g h in
        rewrite ringOpIsDistributiveR i j k in
      abelianGroupRearrange (f <.> h) (g <.> h) (i <.> k) (j <.> k)

  ringOpIsDistributiveL (a :+ x) (b :+ y) (c :+ z) =
    -- Distribute inverses (target x)
    rewrite sym $ multInverseInversesL x (y <+> z) in
      rewrite sym $ multInverseInversesL x y in
        rewrite sym $ multInverseInversesL x z in
    -- Shuffle terms
    rewrite shuffle a b c (inverse x) y z in
      rewrite shuffle a y z x b c in
        Refl where
    shuffle : (f, g, h, i, j, k : t) ->
      f <.> (g <+> h) <+> i <.> (j <+> k) =
        f <.> g <+> i <.> j <+> (f <.> h <+> i <.> k)
    shuffle f g h i j k =
      rewrite ringOpIsDistributiveL f g h in
        rewrite ringOpIsDistributiveL i j k in
      abelianGroupRearrange (f <.> g) (f <.> h) (i <.> j) (i <.> k)

  ringOpIsAssociative (a :+ x) (b :+ y) (c :+ z) =

    let
      b' = inverse b
      y' = inverse y
      bz = b <.> z
      yc = y <.> c
      xbz = x <.> bz
      xyc = x <.> yc
      ay = a <.> y
      ay' = a <.> y'
      xb = x <.> b
      ab = a <.> b
      xb' = x <.> b'
      xy' = x <.> y'
      bc = b <.> c
      y'z = y' <.> z
        in

    -- Distribute inverses (target y if possible, else b)
    rewrite ringOpIsDistributiveL x bz yc in
      rewrite inverseDistributesOverGroupOp xbz xyc in
        rewrite sym $ multInverseInversesR x yc in
          rewrite sym $ multInverseInversesL y c in
        rewrite sym $ multInverseInversesR x bz in
          rewrite sym $ multInverseInversesL b z in
        rewrite sym $ multInverseInversesL y z in
      rewrite sym $ multInverseInversesL (ay <+> xb) z in
        rewrite inverseDistributesOverGroupOp ay xb in
          rewrite sym $ multInverseInversesR a y in
            rewrite sym $ multInverseInversesR x b in
      rewrite sym $ multInverseInversesR x y in

    -- Distribute multiplications
    rewrite ringOpIsDistributiveR ab xy' z in
      rewrite ringOpIsDistributiveR ay xb c in
    rewrite ringOpIsDistributiveL a bz yc in
      rewrite ringOpIsDistributiveL x bc y'z in
    rewrite ringOpIsDistributiveL a bc y'z in
      rewrite ringOpIsDistributiveR ab xy' c in
        rewrite ringOpIsDistributiveR ay' xb' z in

    -- Shuffle the real part
    let
      abc = a <.> bc
      ay'z = a <.> y'z
      xb'z = x <.> (b' <.> z)
      xy'c = x <.> (y' <.> c)
        in
    rewrite shuffle abc ay'z xb'z xy'c in
      rewrite regroup a x b c y' c y' z b' z in

    -- Shuffle the imaginary part
    let
      abz = a <.> bz
      ayc = a <.> yc
      xbc = x <.> bc
      xy'z = x <.> y'z
        in
    rewrite shuffle abz ayc xbc xy'z in
      rewrite regroup a x b z y' z y c b c in

    Refl where

    shuffle : (p, q, r, s : t) ->
      p <+> q <+> (r <+> s) = p <+> s <+> (q <+> r)
    shuffle p q r s =
      rewrite sym $ semigroupOpIsAssociative p q (r <+> s) in
        rewrite abelianGroupOpIsCommutative r s in
          rewrite semigroupOpIsAssociative q s r in
          rewrite abelianGroupOpIsCommutative q s in
        rewrite sym $ semigroupOpIsAssociative s q r in
      semigroupOpIsAssociative p s (q <+> r)

    regroup : (aa, xx, x1, x2, x3, x4, x5, x6, x7, x8 : t) ->
      (aa <.> (x1 <.> x2) <+> xx <.> (x3 <.> x4) <+>
        (aa <.> (x5 <.> x6) <+> xx <.> (x7 <.> x8)))
      =
      (aa <.> x1 <.> x2 <+> xx <.> x3 <.> x4 <+>
        (aa <.> x5 <.> x6 <+> xx <.> x7 <.> x8))
    regroup aa xx x1 x2 x3 x4 x5 x6 x7 x8 =
      rewrite ringOpIsAssociative aa x1 x2 in
        rewrite ringOpIsAssociative aa x5 x6 in
      rewrite ringOpIsAssociative xx x3 x4 in
        rewrite ringOpIsAssociative xx x7 x8 in
      Refl
{% endhighlight %}


# Exercises

1.  Clean up and shorten the **horribly complicated** ring associativity proof.
2.  Some of the proofs here were initially implemented by [**Sventimir**](https://github.com/Sventimir). Later, I came around and reworked them to be shorter and less verbose. One of those initial proofs was left untouched. **Identify it**.
3.  A **left group** is a semigroup with a left neutral element and left inverses for every element; a **right group** is a semigroup with a right neutral element and right inverses for every element. Prove (in Idris, obviously) that every left group is a right group, and vice versa.
4.  [Extra credit] Fix the interface resolution bug described in <sup><a id="fnr.1.100" class="footref" href="#fn.1">1</a></sup>.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> The interfaces described here are not exactly what is currently used in Idris. Instead, for each structure, there are **two interfaces**, a **"plain"** version and a **"verified"** version. The plain version is strictly syntactic, defining only operations and elements that need to exist, while the verified version states relations that are expected to hold. In the case of `Semigroup`, the interfaces are these:

{% highlight idris %}
interface Semigroup t where
  (<+>) : t -> t -> t

interface Semigroup t => VerifiedSemigroup t where
  semigroupOpIsAssociative : (l, c, r : t) ->
    l <+> (c <+> r) = (l <+> c) <+> r
{% endhighlight %}

See [**"Why Aren't Idris Interfaces Verified?"**](https://nickdrozd.github.io/2020/04/23/idris-interfaces.html) for more details.

**In theory** it should be possible to rewrite these proofs with the split plain / verified interfaces, but **in reality** doing this makes the typechecker reject the proofs. It seems to be a **bug** in compiler's interface resolution or whatever it's called, and it is **frustrating**.

This provides an **additional argument** in favor of unifying the interfaces: **it's hard to deal with complicated hierarchies**, so interfaces should be fewer and simpler.

If you want to compile this code yourself, you will need to use [**this branch**](https://github.com/nickdrozd/Idris-dev/tree/verified) (associated with [**this PR**](https://github.com/idris-lang/Idris-dev/pull/4841)).
