---
title: "signed char lotte"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-03-30 Tue&gt;</span></span>
layout: post
categories:
tags:
---
**"signed char lotte"** is a computer program written by [Brian Westley](http://www.westley.org/index2.html) and the winner of the "Best Layout" award in the 1990 **[International Obfuscated C Code Contest](https://www.ioccc.org/years.html#1990)**. The cleverness of the text is staggering. Superficially it reads as an epistolary exchange between two (possibly former) lovers, Charlotte and Charlie. At the same, it is an executable piece of code whose action is thematically related to its story.

It has been argued that **[code is not literature](http://www.gigamonkeys.com/code-reading/)**, and that it cannot be "read" in a straightforward way. "signed char lotte" is not a counterexample to this. The text is essentially a **palimpsest**, with the lovers' storyline written over and obscuring the code that governs the executable behavior. The former can be "read", but not the latter.

Here is the program in full.

{% highlight c %}
char*lie;

	double time, me= !0XFACE,

	not; int rested,   get, out;

	main(ly, die) char ly, **die ;{

	    signed char lotte,


dear; (char)lotte--;

	for(get= !me;; not){

	1 -  out & out ;lie;{

	char lotte, my= dear,

	**let= !!me *!not+ ++die;

	    (char*)(lie=


"The gloves are OFF this time, I detest you, snot\n\0sed GEEK!");

	do {not= *lie++ & 0xF00L* !me;

	#define love (char*)lie -

	love 1s *!(not= atoi(let

	[get -me?

	    (char)lotte-


(char)lotte: my- *love -

	'I'  -  *love -  'U' -

	'I'  -  (long)  - 4 - 'U' ])- !!

p	(time  =out=  'a'));} while( my - dear

	&& 'I'-1l  -get-  'a'); break;}}

	    (char)*lie++;


(char)*lie++, (char)*lie++; hell:0, (char)*lie;

	get *out* (short)ly   -0-'R'-  get- 'a'^rested;

	do {auto*eroticism,

	that; puts(*( out

	    - 'c'

-('P'-'S') +die+ -2 ));}while(!"you're at it");


for (*((char*)&lotte)^=

	(char)lotte; (love ly) [(char)++lotte+

	!!0xBABE];){ if ('I' -lie[ 2 +(char)lotte]){ 'I'-1l ***die; }

	else{ if ('I' * get *out* ('I'-1l **die[ 2 ])) *((char*)&lotte) -=

	'4' - ('I'-1l); not; for(get=!


get; !out; (char)*lie  &  0xD0- !not) return!!

	(char)lotte;}


(char)lotte;

	do{ not* putchar(lie [out

	*!not* !!me +(char)lotte]);

	not; for(;!'a';);}while(

	    love (char*)lie);{


register this; switch( (char)lie

	[(char)lotte] -1s *!out) {

	char*les, get= 0xFF, my; case' ':

	*((char*)&lotte) += 15; !not +(char)*lie*'s';

	this +1s+ not; default: 0xF +(char*)lie;}}}

	get - !out;

	if (not--)

	goto hell;

	    exit( (char)lotte);}
{% endhighlight %}


# Compilation

If you try to compile this today, it will almost certainly not work:

{% highlight shell %}
gcc -w charlotte.c -o charlotte
charlotte.c: In function ‘main’:
charlotte.c:31:7: error: invalid suffix "s" on integer constant
   31 |  love 1s *!(not= atoi(let
      |       ^~
charlotte.c:93:17: error: invalid suffix "s" on integer constant
   93 |  [(char)lotte] -1s *!out) {
      |                 ^~
charlotte.c:99:8: error: invalid suffix "s" on integer constant
   99 |  this +1s+ not; default: 0xF +(char*)lie;}}}
      |        ^~
{% endhighlight %}

The program was written around the time the **C standard** was getting finalized. Prior to standardization, idiosyncratic compiler-specific behavior was more common. One example of this is the **short integer literal suffix**: `1s`. This is akin to the long integer literal suffix: `1l`. Both of these are used in "signed char lotte" and were presumably in common use at the time, but only the long suffix made it into the standard. Thus to compile it, every instance of `1s` must be changed. In the English-language story reading of the text, `1s` stands for the word "is". Fortunately, `1s` can be replaced with `15` to keep the spirit of the text. This change does not affect the program's behavior (!!!).


# Behavior

Speaking of behavior, here is what the program does:

{% highlight nil %}
$ ./charlotte 5

./charlotte
loves me
./charlotte
loves me, not
./charlotte
loves me
./charlotte
loves me, not
./charlotte
loves me
{% endhighlight %}

The author comments:

> This is a **"Picking the Daisy" simulation**.  Now, instead of mangling a daisy, simply run this program with the number of petals desired as the argument.

Despite the simplicity of the behavior, it is utterly unclear how the program manages to implement it. **Figuring out how it works is an instructive exercise**, and the reader might want to attempt it before reading further.


# Formatting

Running the code through a **formatter** is a a necessary first step, but not a sufficient one. Some manual fixes to the formatted output will probably be required, as formatters are generally not prepared to deal with such bizarre structure. Properly formatted, the program looks something like this:

{% highlight c %}
char *lie;
double time, me = !0XFACE, not;
int rested, get, out;

main(ly, die) char ly, **die;
{
  signed char lotte, dear;
  (char)lotte--;

  for (get = !me;; not) {
    1 - out &out;
    lie;
    {
      char lotte, my = dear, **let = !!me * !not + ++die;

      (char *)(lie = "The gloves are OFF this time, I detest you, snot\n\0sed GEEK!");

      do {
        not = *lie++ & 0xF00L * !me;

        (char *)lie - 1 * !(not = atoi(let[get - me ? (char)lotte - (char)lotte : my - *(char *)lie - -'I' - *(char *)lie - -'U' - 'I' - (long)-4 - 'U']) - !!(time = out = 'a'));
      } while (my - dear && 'I' - 1l - get - 'a');

      break;
    }
  }

  (char)*lie++;
  (char)*lie++, (char)*lie++;

hell:
  0, (char)*lie;

  get *out *(short)ly - 0 - 'R' - get - 'a' ^ rested;

  do {
    auto *eroticism, that;
    puts(*(out - 'c' - ('P' - 'S') + die + -2));
  } while (!"you're at it");

  for (*((char *)&lotte) ^= (char)lotte;
       ((char *)lie - ly)[(char)++lotte + !!0xBABE];) {
    if ('I' - lie[2 + (char)lotte]) {
      'I' - 1l * **die;
    } else {
      if ('I' * get * out * ('I' - 1l * *die[2]))
        *((char *)&lotte) -= '4' - ('I' - 1l);
      not;
      for (get = !get; !out; (char)*lie & 0xD0 - !not)
        return !!(char)lotte;
    }

    (char)lotte;

    do {
      not*putchar(lie[out * !not*!!me + (char)lotte]);
      not;
      for (; !'a';);
    } while ((char *)lie - (char *)lie);

    {
      register this;
      switch ((char)lie[(char)lotte] - 1 * !out) {
        char *les, get = 0xFF, my;

      case ' ':
        *((char *)&lotte) += 15;
        !not + (char)*lie * 's';
        this + 1 + not;

      default:
        0xF + (char *)lie;
      }
    }
  }

  get - !out;

  if (not--)
    goto hell;

  exit((char)lotte);
}
{% endhighlight %}

It remains unclear how the program actually does what it does. The primary obfuscation trick used is **misdirection**. You can spend a lot of time trying to work out the purpose and meaning of every line, but in fact **most of the code is totally useless**. Shall I count the ways?


# Useless casts

All of the following casts can be cut without consequence:

-   `(char)`
-   `(char*)`
-   `(long)`
-   `(short)`


# Useless statements

Many statements have no effect on anything, and can be cut. A simple example of a useless statement is `(char)lotte;`; it evidently casts `signed char lotte` as a `char` and then does nothing with it. Obviously this can be cut.

More sophisticated useless statements can be constructed from arithmetic operators:

-   `1 -  out & out ;lie;`
-   `get - !out;`
-   `get *out* (short)ly   -0-'R'-  get- 'a'^rested;`

However, a statement that appears useless may not be. Because this is good old dependable C, **side effects** can occur just about anywhere, and it is all but impossible to tell how any one in particular might affect the program's behavior. Thus any statement with the following operators must be kept: `=`, `++`, `--`, `+=`, `^=`.


# Useless Control Flow

A nice way to add in some extra words to the program without affecting its operation is to wrap a code block in a `do` loop with an always-false `while` condition. This causes the code to execute exactly as before, but with a superficially more complex control flow. Here is my favorite example:

{% highlight c %}
#define love (char*)lie -

// ...

do{ not* putchar(lie [out

*!not* !!me +(char)lotte]);

not; for(;!'a';);}while(

    love (char*)lie);{
{% endhighlight %}

With formatting and preprocessor expansion, this becomes:

{% highlight c %}
do {
  not*putchar(lie[out * !not*!!me + (char)lotte]);
  not;
  for (; !'a';);
} while ((char *)lie - (char *)lie);
{% endhighlight %}

But `(char *)lie - (char *)lie` will **always work out to be falsy**, and therefore the expression can be reduced to a simple block:

{% highlight c %}
not*putchar(lie[out * !not*!!me + (char)lotte]);
not;
for (; !'a';);
{% endhighlight %}

This block itself contains the strikingly useless loop `for (; !'a';);`, as well as the useless simple statement `not;`.

Besides overtly useless control flow, specific quirks of C control flow operators can be exploited. For example, code in a `switch` block that comes before any of the `case` labels is unreachable, and therefore useless.

{% highlight c %}
switch ((char)lie[(char)lotte] - 1 * !out) {
  char *les, get = 0xFF, my;  // unreachable

case ' ':
  *((char *)&lotte) += 15;
  !not + (char)*lie * 's';
  this + 1 + not;

default:
  0xF + (char *)lie;
}
{% endhighlight %}


# The Crux of the Program

After applying these simplfications and doing a little more massaging, the true nature of the program reveals itself:

{% highlight c %}
char *lie = "loves are OFF this time, I detest you, snot\n\0";

int main(int argc, char **argv) {
  int get = 1;
  int not = atoi(argv[1]);

  int lotte;

  for (; not; not--) {
    puts(argv[0]);

    for (lotte = 0; lie[lotte]; lotte++) {
      if (!('I' - lie[2 + lotte])) {
        if (get)
          lotte += 20;

        get = !get;
      }

      putchar(lie[lotte]);

      switch (lie[lotte]) {
      case ' ':
        lotte += 15;
      }
    }
  }

  exit(lotte);
}
{% endhighlight %}

The string `char *lie` contains as substrings "loves", "me", and "not". `get` is a toggle that signals whether or not to print "not", while `not` is the counter input by the user. `lotte` is the index into `lie`. The program uses **comically elaborate logic** with hard-coded constants to manipulate `lotte` into the right position in `lie`, and that's how the appropriate messages are printed.

Thus it is not merely a matter of obfuscating an otherwise normal program by covering it up with a bunch of weird irrelevant text; **fundamentally the program is already far more difficult to understand than it needs to be**. The IOCCC judges said that they "like programs that MAKE USE OF A NUMBER OF DIFFERENT TYPES OF OBFUSCATION", and so it is no surprise that "signed char lotte" won.


# Discussion Questions

1.  How many reserved keywords are there in C? How many of those are used in "signed char lotte"?
2.  Why wasn't the short integer literal suffix included in the C standard? How common was it in pre-standard times? Which compilers included it?
3.  Is love a toilet?
4.  What is the purpose of the `goto hell;` statement?
5.  How do you suppose this program was constructed?


# Exercises

1.  Analyze Westley's 1987 IOCCC winner, ["Able was I ere I saw elbA"](https://www.ioccc.org/1987/westley/westley.c).
2.  Modify "signed char lotte" so as to include more C keywords.
3.  Modify GCC so that it compiles the original program correctly.
