Sphinx Search
=============

### Installation

1. Install Sphinx
1. Install Aspell and at least one Aspell dictionary
      Mac:
        sudo port install aspell aspell-dict-en

      Ubuntu:
        sudo apt-get install aspell libaspell-dev aspell-en

1. Add to Gemfile: `gem 'spree-sphinx-search', :path => git://github.com/romul/spree-sphinx-search.git`
1. Run `rails g spree_sphinx_search:install`

**NOTE:** This extension works only with Spree 1.0 and higher.

### Usage

To perform the indexing:

    rake ts:config
    rake ts:index

To start Sphinx for development:

    rake ts:start
