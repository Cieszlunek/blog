docker run --rm --volume="C:/Users/jsamc/projekty/blog:/srv/jekyll:Z" --volume="C:/Users/jsamc/projekty/blog/vendor/bundle:/usr/local/bundle:Z" -p 4000:4000 -p 35729:35729 -it jekyll/jekyll:3.8 jekyll serve --watch