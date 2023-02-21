# `query-replace-many`

This package exposes `query-replace-many`, a function that works like `query-replace`, only it works on multiple matches;
that is, the user can specify multiple `(from . to)` replacement pairs, and an empty query finalises the selection.
For example, in the following, existing occurences of `T` are replaced by `U`, and existing ones of `U` by `T`:

![](https://user-images.githubusercontent.com/50166980/220303461-1ae83a8b-ed87-47b1-8107-c7efcd215b38.gif)

A blog post, explaining some of the motivation behind the package, is available [here][blog:query-replace-many].

[blog:query-replace-many]: https://tony-zorman.com/posts/query-replace-many.html

## Installation

### With `vc-use-package`

If you use Emacs 29+ and [vc-use-package], you can install this package via

``` emacs-lisp
(use-package query-replace-many
  :vc (:fetcher github :repo "slotThe/query-replace-many")
  :bind ("C-M-%" . query-replace-many))
```

[vc-use-package]:https://github.com/slotThe/vc-use-package

### Manually with `use-package`

Simply `git clone` the repository somewhere, and then load the package as normal:

``` emacs-lisp
(use-package query-replace-many
  :load-path "/path/to/repo/"
  :bind ("C-M-%" . query-replace-many))
```
