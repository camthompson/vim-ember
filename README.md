# ember.vim

It's like [vim-rails][vim-rails], but it's for [Ember][ember].

* Navigation commands. Use `:Emodel`, `:Ecomponent`, etc., to `:edit` files. The `V`, `S`, and `T` variants use `:vsplit`, `:split`, and `:tabedit`, respectively.
* [ember-cli][ember-cli] interface. Run `:Egenerate` and `:Edestroy` from inside vim. `:Egenerate model foo` generates the foo model and loads the generated files into the quickfix list.

## Credits

All credit is due to His Holyness [tpope][tpope]. I basically cloned [vim-rails][vim-rails] and `s/rails/ember`ed.

## Self Promotion

If you like this plugin, let's be internet friends on [Twitter][twitter] or [GitHub][github].

## Dependencies

Install [projectionist][projectionist] for the navigation commands.

## License

Copyright (c) [Cam Thompson](http://camthompson.com). Distributed under the same terms as Vim itself. See `:help license`.

[vim-rails]: https://github.com/tpope/vim-rails
[ember]: http://emberjs.com
[twitter]: https://twitter.com/camthompson
[github]: https://github.com/camthompson
[ember-cli]: http://www.ember-cli.com
[tpope]: https://github.com/tpope
[projectionist]: https://github.com/tpope/vim-projectionist
