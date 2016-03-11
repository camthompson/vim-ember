# ember.vim

It's like [vim-rails][vim-rails], but it's for [Ember][ember].

* Navigation commands. Use `:Emodel`, `:Ecomponent`, etc., to `:edit` files. The `V`, `S`, and `T` variants use `:vsplit`, `:split`, and `:tabedit`, respectively.
* [ember-cli][ember-cli] interface. Run `:Egenerate` and `:Edestroy` from inside vim. `:Egenerate model foo` generates the foo model and loads the generated files into the quickfix list.
* [vim-surround][surround] integration. In Handlebars files, use `{` to surround in mustaches. In JavaScript files, use `g` to surround in `this.get('')`, `s` to surround in `this.set('')`, and `$` to surround in `${}`.

## Dependencies

* Install [projectionist][projectionist] for the navigation commands.
* Install [surround][surround] for the surround maps.

## Credits

All credit is due to His Holyness [tpope][tpope]. I basically cloned [vim-rails][vim-rails] and `s/rails/ember`ed.

## Self Promotion

If you like this plugin, let's be internet friends on [Twitter][twitter] or [GitHub][github].

## License

Copyright (c) [Cam Thompson](http://camthompson.com). Distributed under the same terms as Vim itself. See `:help license`.

[vim-rails]: https://github.com/tpope/vim-rails
[ember]: http://emberjs.com
[twitter]: https://twitter.com/camthompson
[github]: https://github.com/camthompson
[ember-cli]: http://www.ember-cli.com
[tpope]: https://github.com/tpope
[projectionist]: https://github.com/tpope/vim-projectionist
[surround]: https://github.com/tpope/vim-surround
