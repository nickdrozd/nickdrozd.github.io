---
title: "Why Aren't Idris Interfaces Verified?"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-04-23 Thu&gt;</span></span>
layout: post
categories:
tags:
---

# Table of Contents


A **semigroup** is a set *S* equipped with a binary operation *+* which is **associative**; that is, for any *a, b, c* in *S*, *a + (b + c) = (a + b) + c*. The natural numbers *0, 1, 2, &#x2026;* form a semigroup under both addition and multiplication, but *not* under subtraction, since *3 - (2 - 1)* is 2, but *(3 - 2) - 1* is *0*.

Here is the definition (truncated) of the semigroup class in [**Haskell**](https://hackage.haskell.org/package/base-4.12.0.0/docs/src/GHC.Base.html#Semigroup):

{% highlight haskell %}
-- | The class of semigroups (types with an associative binary operation).
--
-- Instances should satisfy the associativity law:
--
--  * @x '<>' (y '<>' z) = (x '<>' y) '<>' z@
--
class Semigroup a where
        -- | An associative operation.
        (<>) :: a -> a -> a
{% endhighlight %}

The semigroup operation is a binary operation, and that is reflected by the signature `(<>) :: a -> a -> a`. But what about associativity? The docstring says that the operation "should" be associative, and there is a comment in the code itself: `-- | An associative operation.` Who is that comment trying to convince? Perhaps the comment is a **symptom of anxiety** about the fact that **associativity is not enforced** in the class definition.

A **monoid** is a semigroup with a **neutral** element; that is, an element *e* such that for every *x* in *S*, *e + x = x = x + e*. Here is the [source](https://hackage.haskell.org/package/base-4.12.0.0/docs/src/GHC.Base.html#Monoid) (truncated):

{% highlight haskell %}
-- | The class of monoids (types with an associative binary operation that
-- has an identity).  Instances should satisfy the following laws:
--
--  * @x '<>' 'mempty' = x@
--
--  * @'mempty' '<>' x = x@
--
class Semigroup a => Monoid a where
        -- | Identity of 'mappend'
        mempty  :: a
{% endhighlight %}

Again, the docstring and the overinsistent comment make some **claims** about the properties of the neutral element, but those claims are not enforced by the typechecker.

But wait, what exactly is the claim being made? "Instances **should** satisfy the following laws&#x2026;". What kind of claim is this? **What does it mean** to say of code that it "should" have some property? Is such a "should"-claim **true**? Is it **false**? Is it true or false at all, or is it something else?

This kind of talk comes up a lot when these classes are discussed. Let's see what [*Learn You a Haskell*](http://learnyouahaskell.com/functors-applicative-functors-and-monoids) has to say about monoids (emphases mine):

> We mentioned that there **has to** be a value that acts as the identity
> with respect to the binary function and that the binary function has
> to be associative. It's possible to make instances of Monoid that
> don't **follow these rules**, but such instances are of no use to anyone
> because when using the Monoid type class, we rely on its instances
> acting like monoids. Otherwise, what's the point? That's why when
> making instances, we **have to** make sure they **follow these laws**&#x2026;

[School of Haskell](https://www.schoolofhaskell.com/user/tbelaire/monoids):

> [The identity] **must** have the property that&#x2026;

[Some blog](http://blog.sigfpe.com/2009/01/haskell-monoids-and-their-uses.html):

> [W]e also **require** monoids to **obey** these two **rules**&#x2026;

[Another blog](https://mjoldfield.com/atelier/2015/04/monoid.html):

> [The associative operator and the identity element] are **subject to laws**&#x2026;

[Yet another blog](http://www.haskellforall.com/2020/04/blazing-fast-fibonacci-numbers-using.html):

> The only **rule** for this Semigroup interface is that the operator we implement **must obey** the following associativity **law**&#x2026;

And so on. Two sets of vocabulary show up over and over. On the one hand, the **authoritarian** language of **law and order** &#x2013; laws, rules, obedience, subjection; on the other hand, the **deontic** language of **ethics and morality**: "should", "must", "has to", "ought to", and so on.

This is not the transparent language of code, it is the murky language of humans. It suggests that there are **requirements that cannot be built into the code**. The language (Haskell) does not support formal specifications like this, so verification is left to humans. How exactly this gets worked out might differ in various circumstances, but for the most part it seems to require **trust**. The user of an instance **assumes** that the expected properties hold, while the implementor, by virtue of having implemented the class, implicitly **assures** that this is the case.

This state of affairs is the result of a **shortcoming** of Haskell and languages like it, namely that they don't support **proofs** and therefore cannot **verify** claims like associativity and neutrality. In a **dependently-typed** language like **Idris**, requirements and "laws" can be built right into the code, with no need for squishy "shoulds" and "musts". Here are Idris definitions for semigroup and monoid:

{% highlight idris %}
||| Sets equipped with a single binary operation that is associative.
|||
||| + Associativity of `<+>`:
|||     forall a b c, a <+> (b <+> c) == (a <+> b) <+> c
interface Semigroup ty where
  (<+>) : ty -> ty -> ty

  semigroupOpIsAssociative : (l, c, r : ty) ->
    l <+> (c <+> r) = (l <+> c) <+> r

||| Sets equipped with a single binary operation that is associative,
||| along with a neutral element for that binary operation.
|||
||| + Associativity of `<+>`:
|||     forall a b c, a <+> (b <+> c) == (a <+> b) <+> c
||| + Neutral for `<+>`:
|||     forall a,     a <+> neutral   == a
|||     forall a,     neutral <+> a   == a
interface Semigroup ty => Monoid ty where
  neutral : ty

  monoidNeutralIsNeutralL : (l : ty) -> l <+> neutral = l
  monoidNeutralIsNeutralR : (r : ty) -> neutral <+> r = r
{% endhighlight %}

And that's that. No "shoulds", no "musts", just **straightforward descriptions**. If I have an instance of `Semigroup`, I don't need to worry about whether or not that it "obeys the laws"; the fact that it compiled in the first place assures me that properties were proved (with some caveats; see below). The operator of a semigroup **just is** associative.

Sometimes proving these properties is hard, and sometimes it's easy. Here's an easy one:

{% highlight idris %}
Semigroup (Maybe a) where
  Nothing   <+> m = m
  (Just x)  <+> _ = Just x

  semigroupOpIsAssociative (Just _) _        _ = Refl
  semigroupOpIsAssociative Nothing  (Just _) _ = Refl
  semigroupOpIsAssociative Nothing  Nothing  _ = Refl
{% endhighlight %}

Here's a harder one:

{% highlight idris %}
Semigroup a => Semigroup (Vect n a) where
  (<+>)= zipWith (<+>)

  semigroupOpIsAssociative [] [] [] = Refl
  semigroupOpIsAssociative (x :: xs) (y :: ys) (z :: zs) =
    rewrite semigroupOpIsAssociative x y z in
      rewrite semigroupOpIsAssociative xs ys zs in
        Refl
{% endhighlight %}

**BUT WAIT**

Those definitions are *possible* Idris definitions of those structures, but they are not the *official* ones. **Officially**, they are defined like this:

{% highlight idris %}
||| Sets equipped with a single binary operation that is associative.
||| Must satisfy the following laws:
|||
||| + Associativity of `<+>`:
|||     forall a b c, a <+> (b <+> c) == (a <+> b) <+> c
interface Semigroup ty where
  (<+>) : ty -> ty -> ty

||| Sets equipped with a single binary operation that is associative,
||| along with a neutral element for that binary operation. Must
||| satisfy the following laws:
|||
||| + Associativity of `<+>`:
|||     forall a b c, a <+> (b <+> c) == (a <+> b) <+> c
||| + Neutral for `<+>`:
|||     forall a,     a <+> neutral   == a
|||     forall a,     neutral <+> a   == a
interface Semigroup ty => Monoid ty where
  neutral : ty
{% endhighlight %}

These are just like the squishy Haskell definitions, "musts" and all. In order to take advantage of **language-level support for proofs**, there are corresponding "verified" definitions:

{% highlight idris %}
interface Semigroup a => VerifiedSemigroup a where
  semigroupOpIsAssociative : (l, c, r : a) ->
    l <+> (c <+> r) = (l <+> c) <+> r

interface (VerifiedSemigroup a, Monoid a) => VerifiedMonoid a where
  monoidNeutralIsNeutralL : (l : a) -> l <+> neutral = l
  monoidNeutralIsNeutralR : (r : a) -> neutral <+> r = r
{% endhighlight %}

The "verification" is available basically as a **mix-in**. It is **optional**, and the "plain" version can be implemented without the "verification".

This seems to me like **bad idea**, so I [**proposed to change it**](https://groups.google.com/forum/#!topic/idris-lang/VZVpi-QUyUc). Of course, it's much easier to **talk shit** than it is to implement a change of that scope, so I also [**opened a PR**](https://github.com/idris-lang/Idris-dev/pull/4841) to implement it too. There was some spirited discussion, but I don't think the proposal will get accepted. **There are two reasons, one technical and one social.**

The technical reason is that Idris (along with most  things related to type theory) does not have **extensional equality**. This means that **functions cannot be proved to be equal** even when they have exactly the same outputs. Several common cases of Semigroup and Monoid need proofs of  function equality for "verification", and since that is impossible, it is argued, verification shouldn't be required.

Personally, I am suspicious of non-extensionality<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>, but even setting that aside, I am not convinced by this argument. For Idris provides the **`postulate`** mechanism to enable the use of **unproved statements**, and postulates can be used to fill in **unprovable holes**. Here is an example:

{% highlight idris %}
postulate private
morphism_assoc : Semigroup a => (f, g, h : r -> a) ->
  Mor (\r => f r <+> (g r <+> h r)) = Mor (\r => f r <+> g r <+> h r)

Semigroup a => Semigroup (Morphism r a) where
  f <+> g = [| f <+> g |]

  semigroupOpIsAssociative (Mor f) (Mor g) (Mor h) = morphism_assoc f g h
{% endhighlight %}

From a correctness perspective, there is nothing wrong with this. *If* Morphisms *really are* associative, then no false consquences can arise out of it. In other words, the postulate is **consistent** with the rest of the language. True postulates can be added on a case-by-case basis with impunity.

I used postulates in several places in that PR<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup>, and somebody accused me of wanting to **have it both ways**, demanding that proofs be provided while falling back on postulates when I couldn't prove something. But even this is an improvement on the existing arrangement. Currently, the implementor implicitly assures that their implementation "obeys the laws" of the interface. With the postulate approach, the same assurance is made, but it is made **explicitly**. And as the **Zen of Python** says,

> Explicit is better than implicit.

Before moving on to the **social reason** for rejecting verification by default, let's stop and consider: **why aren't Haskell interfaces verified?** Haskellers are well-known for bragging about the safety from errors their language affords them, and "theorems for free" and all that. Why would such fastidious people **leave it up to implementors** to ensure on their own that their semigroups and monoids really do have the properties that they "should" have, that they "obey the laws"? I take it that it's because Haskell the language does not provide a mechanism for verification. It can't be done in the language, so they have to rely on **side-channel human verification** instead. It wasn't a choice that was made, it was just a circumstance.

So now here we are with Idris, where it *is* possible to verify. Non-verification is not a circumstance to be dealt with, it is choice that has been made. Why? I think the answer is basically **tradition** and a kind of **quasi-backwards-compatibility**. The reasoning might go something like this:

> Yes, it is not ideal to have two interfaces for each structure, and if we were designing these interfaces from scratch, then perhaps we would verify by default, since that would mean that an implemented structure really is what the docstring says it is. But we aren't designing these interfaces from scratch: they are inherited from Haskell, and they are the way they are because verification is not possible there. Idris is intended to hew pretty close to Haskell, and in particular, Haskell code ought to "just work" in Idris (modulo minor syntactic differences). Thus the current system of opt-in verification is a means of preserving a kind of backwards compatibility with Haskell.

Is that a good reason? **Maybe.** I guess it depends on your priorities. I don't come from Haskell, so I don't care about compatibility with Haskell interfaces, but maybe I'm an outlier among Idris users in that respect.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> Non-extensionality is also known as **intentionality**. See [this](https://mathoverflow.net/questions/156238/function-extensionality-does-it-make-a-difference-why-would-one-keep-it-out-of) and [this](https://homotopytypetheory.org/2014/02/17/another-proof-that-univalence-implies-function-extensionality/) for details.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> I also used a mechanism called `believe_me`, which is apparently not the right thing to use in this case. `really_believe_me` is also not the right thing to use. I don't understand the difference between them, or what exactly either of them do.
