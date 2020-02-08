.PHONY : all blog drafts

all : blog

blog :
	bundle exec jekyll serve

drafts :
	bundle exec jekyll server --drafts
