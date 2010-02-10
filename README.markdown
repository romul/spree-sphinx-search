Sphinx Search
=============

### Installation

1. Install Sphinx 0.9.9
1. Install Aspell 0.6 and at least one Aspell dictionary
      Mac: 
        sudo port install aspell aspell-dict-en

      Ubuntu: 
        sudo apt-get install aspell libaspell-dev aspell-en
  
1. `script/extension install git://github.com/romul/spree-sphinx-search.git`

**NOTE:** This extension works only with Spree 0.9.99 and higher.
    
### Usage

To perform the indexing:

    rake ts:index

To start Sphinx for development:

    cd RAILS_ROOT/config
    sphinxd --config development.sphinx.conf


