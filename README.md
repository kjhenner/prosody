## What is versify?

Versify uses a weighted graph model and sundry prosodic filters to generate bad poetry from a source corpus.

My great optimism: that long after the last of *Homo sapiens sapiens* has passed on from
being, our synthetic successors will carry some doggerel shred of our artistic irrationality
out into the universe. Versify is my fumbling towards this dream.

## How to install versify

Versify requires the [Treat](https://github.com/louismullie/treat) gem.

    gem install treat

I intend to publish Versify as a gem. Until then, clone the repository
and `load 'lib/versiby.rb'` in `irb`.

## How to use versify

(Note that this process is sub-optimal and will change [possibly for the better].
I'll try to keep this README updated, but it may drift.)

From the repository directory, run `irb` and `load 'lib/versify.rb`.

To parse and serialize a source text, first save that file in the data directory. (In the following example,
I use James Frazer's *The Golden Bough* from Project Gutenberg.) With the source file in place, use the Graph
class to parse the file and serialize the resulting graph as JSON before saving it to the disk.

    g = Graph.new
    t = g.load_tokens_from_text('data/golden_bough.txt')
    b = g.get_bigrams_from_tokens(t)
    g.nodes_from_bigrams(b)
    g.serialize(golden_bough)

Load a serialized graph:

    g = Graph.new 'golden_bough'

Use the `load_json` as an alternate way to load a serialized graph or if you want to add another source file to an
existing graph:

    g.load_json 'mobydick'
    
To generate a poem, create a new Poem instance. Supply it with your graph, and specify the desired line length (in bigrams)
and rhyme scheme as a string (e.g. 'abba').

    p = Poem.new(g, 3, 'aabb')
    p.generate

